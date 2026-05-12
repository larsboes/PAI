# SQL Query Optimization Reference

## 1. Query Analysis

### Reading EXPLAIN Output

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT ...;
```

| Field | Meaning |
|-------|---------|
| `Seq Scan` | Full table scan — no index used |
| `Index Scan` | B-tree lookup + heap fetch |
| `Index Only Scan` | Answered entirely from index (covering) |
| `Bitmap Index Scan` | Index → bitmap → heap (multiple ranges) |
| `cost=0.00..X` | Startup cost..total cost (arbitrary units) |
| `rows=N` | Estimated row count (compare to `actual rows`) |
| `loops=N` | Times this node executed — multiply by rows for true count |

### Join Algorithms

| Algorithm | Best When | Cost |
|-----------|-----------|------|
| **Nested Loop** | Small outer, indexed inner | O(n*m) worst, O(n*log m) with index |
| **Hash Join** | Equi-joins, no useful index | O(n+m), needs memory for hash table |
| **Merge Join** | Pre-sorted inputs, large datasets | O(n log n + m log m), or O(n+m) if sorted |

---

## 2. Indexing Strategies

### Index Types

| Type | Use Case | Example |
|------|----------|---------|
| **B-tree** (default) | Equality, range, sorting, LIKE 'prefix%' | `CREATE INDEX idx ON t(col)` |
| **Hash** | Equality only (rarely better than B-tree) | `CREATE INDEX idx ON t USING hash(col)` |
| **GIN** | Arrays, JSONB, full-text search | `CREATE INDEX idx ON t USING gin(jsonb_col)` |
| **GiST** | Geometric, range types, full-text | `CREATE INDEX idx ON t USING gist(geom_col)` |

### Composite Index Column Order

```sql
-- Rule: equality columns FIRST, then range/sort columns
-- Query: WHERE status = 'active' AND created_at > '2024-01-01' ORDER BY created_at
CREATE INDEX idx ON orders(status, created_at);  -- GOOD: equality then range
CREATE INDEX idx ON orders(created_at, status);  -- BAD: range first kills selectivity
```

### Partial & Covering Indexes

```sql
-- Partial: index only rows that matter
CREATE INDEX idx_active ON orders(created_at) WHERE status = 'active';

-- Covering: include columns to enable index-only scans
CREATE INDEX idx_cover ON orders(user_id) INCLUDE (total, status);
```

### When NOT to Index

- Tables under ~10K rows (seq scan is fine)
- Columns with low cardinality (boolean, status with 2-3 values) unless partial index
- Write-heavy tables where read performance isn't critical
- Columns never used in WHERE, JOIN, or ORDER BY

---

## 3. Common Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| `SELECT *` | Excess I/O, blocks covering index scans | List needed columns explicitly |
| N+1 queries | 1 query + N child queries in a loop | Use JOIN or batch IN() |
| `WHERE YEAR(created_at) = 2024` | Function on indexed column kills index | `WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01'` |
| Implicit type cast | `WHERE id = '123'` when id is INT | Match types explicitly |
| `OR` on different columns | Prevents single index use | Rewrite as `UNION ALL` of two indexed queries |
| Correlated subquery | Re-executes per row | Rewrite as JOIN or lateral join |
| `OFFSET 10000 LIMIT 20` | Scans and discards 10K rows | Use keyset pagination (see below) |

---

## 4. Optimization Patterns

### CTEs: Materialized vs Not

```sql
-- PostgreSQL 12+: NOT MATERIALIZED (default for simple CTEs) — optimizer can inline
WITH cte AS NOT MATERIALIZED (SELECT ... WHERE ...)
SELECT * FROM cte WHERE ...;

-- Force materialization when CTE is referenced multiple times
WITH cte AS MATERIALIZED (SELECT expensive_function() ...)
SELECT * FROM cte a JOIN cte b ON ...;
```

### Window Functions Over Self-Joins

```sql
-- BAD: self-join to get previous row
SELECT a.*, b.value AS prev_value
FROM events a LEFT JOIN events b ON b.id = (
    SELECT MAX(id) FROM events WHERE id < a.id AND user_id = a.user_id
);

-- GOOD: window function
SELECT *, LAG(value) OVER (PARTITION BY user_id ORDER BY id) AS prev_value
FROM events;
```

### EXISTS vs IN vs JOIN

```sql
-- EXISTS: best when checking existence, stops at first match
SELECT * FROM orders o WHERE EXISTS (SELECT 1 FROM users u WHERE u.id = o.user_id AND u.active);

-- IN: fine for small subquery results, optimizer often rewrites to semi-join
SELECT * FROM orders WHERE user_id IN (SELECT id FROM users WHERE active);

-- JOIN: when you need columns from both tables (beware duplicates if not 1:1)
```

### Keyset Pagination

```sql
-- BAD: offset pagination degrades linearly
SELECT * FROM items ORDER BY id LIMIT 20 OFFSET 10000;

-- GOOD: keyset pagination — constant performance
SELECT * FROM items WHERE id > :last_seen_id ORDER BY id LIMIT 20;
```

### Batch Operations

```sql
-- BAD: row-by-row insert
INSERT INTO t(col) VALUES (1); INSERT INTO t(col) VALUES (2); ...

-- GOOD: batch insert
INSERT INTO t(col) VALUES (1), (2), (3), ... ;

-- GOOD: batch update with VALUES
UPDATE t SET status = v.status
FROM (VALUES (1,'done'),(2,'done'),(3,'failed')) AS v(id, status)
WHERE t.id = v.id;
```

---

## 5. PostgreSQL-Specific

### Maintenance

```sql
-- Update planner statistics (run after bulk loads)
ANALYZE table_name;

-- Reclaim dead tuples (autovacuum handles this, but manual after big deletes)
VACUUM (VERBOSE) table_name;

-- Find slow queries
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 20;
```

### Connection Pooling

- **PgBouncer** in `transaction` mode for most apps (releases conn after each tx)
- `session` mode only if using prepared statements or temp tables
- Set `pool_size` = 2-3x CPU cores on the DB server, not higher

### Table Partitioning

```sql
-- Range partition by date (most common)
CREATE TABLE events (id bigint, created_at timestamptz, data jsonb)
PARTITION BY RANGE (created_at);

CREATE TABLE events_2024_q1 PARTITION OF events
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
```

Use when: single table > 100M rows, queries always filter on partition key, need fast DROP of old data.

### JSONB Indexing

```sql
-- GIN index on entire JSONB (supports @>, ?, ?|, ?& operators)
CREATE INDEX idx_data ON t USING gin(data);

-- Expression index on specific key (supports =, <, >, etc.)
CREATE INDEX idx_data_type ON t ((data->>'type'));

-- GIN on specific path (lighter than whole-document GIN)
CREATE INDEX idx_data_tags ON t USING gin((data->'tags'));
```

---

## 6. Performance Checklist

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Slow single-row lookup | Missing index on WHERE column | Add B-tree index |
| Query fast alone, slow under load | Lock contention or connection exhaustion | Add PgBouncer, check `pg_stat_activity` |
| Sequential scan on indexed column | Stale statistics or low estimated selectivity | `ANALYZE table_name`, check data distribution |
| Join explodes row count | Missing or wrong join condition, many-to-many | Add proper ON clause, use DISTINCT or EXISTS |
| Query slows over time | Table bloat (dead tuples) | Check autovacuum, run `VACUUM FULL` |
| Pagination gets slower on later pages | OFFSET-based pagination | Switch to keyset pagination |
| JSONB queries slow | No GIN index, or using `->` in WHERE | Add GIN index, use `@>` operator |
| INSERT/UPDATE throughput drops | Too many indexes on the table | Drop unused indexes (`pg_stat_user_indexes`) |
| High memory usage in query | Hash join on huge table, bad work_mem | Increase `work_mem` for session, or restructure query |
| Planner picks wrong plan | Stale stats or parameter sniffing | `ANALYZE`, consider `plan_cache_mode = force_custom_plan` |
