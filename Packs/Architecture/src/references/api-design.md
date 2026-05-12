# API Design Patterns

Practical patterns for REST, GraphQL, security, versioning, errors, performance, and documentation. Decision-oriented — pick the right pattern for your context.

---

## REST Design

### Resource Naming

```
✅ /users/123/orders          — nouns, plural, nested for ownership
✅ /orders?user_id=123        — flat with filter (preferred for non-ownership)
❌ /getOrdersByUser/123       — verbs in URLs
❌ /user/order                — singular (inconsistent)
```

Use kebab-case for multi-word resources: `/line-items`, not `/lineItems`.

### HTTP Methods

| Method | Semantics | Idempotent | Request Body | Response Body |
|--------|-----------|------------|--------------|---------------|
| GET | Read | Yes | No | Resource |
| POST | Create / Action | No | Yes | Created resource |
| PUT | Full replace | Yes | Yes | Updated resource |
| PATCH | Partial update | Yes* | Yes | Updated resource |
| DELETE | Remove | Yes | No | Empty / confirmation |

*PATCH is idempotent if you use merge-patch (`application/merge-patch+json`), not if you use JSON Patch operations.

### Status Codes — Decision Table

| Code | When to use |
|------|-------------|
| 200 | Successful GET, PUT, PATCH, or action that returns data |
| 201 | POST created a resource — include `Location` header |
| 204 | Successful DELETE or action with no response body |
| 400 | Malformed request (invalid JSON, wrong types) |
| 404 | Resource doesn't exist |
| 409 | Conflict (duplicate email, version mismatch, state transition error) |
| 422 | Well-formed but semantically invalid (business rule violation) |
| 429 | Rate limit exceeded — include `Retry-After` header |
| 500 | Server error — never leak stack traces |

**400 vs 422:** 400 = can't parse it. 422 = parsed it, but the content violates rules.

### Versioning

| Strategy | Pros | Cons | Use when |
|----------|------|------|----------|
| URL (`/v2/users`) | Obvious, easy routing | URL pollution, breaks caches | Public APIs, major versions |
| Header (`Accept: application/vnd.api+json;v=2`) | Clean URLs | Hidden, harder to test | Internal APIs, fine-grained |
| Query (`?version=2`) | Easy to test | Pollutes cache keys | Quick prototyping only |

**Recommendation:** URL versioning for public APIs. Increment only on breaking changes.

### Pagination

```json
// Cursor-based (preferred for real-time data, large datasets)
GET /orders?cursor=eyJpZCI6MTIzfQ&limit=25
{
  "data": [...],
  "pagination": { "next_cursor": "eyJpZCI6MTQ4fQ", "has_more": true }
}

// Offset-based (acceptable for stable, small datasets)
GET /orders?offset=50&limit=25
{
  "data": [...],
  "pagination": { "total": 200, "offset": 50, "limit": 25 }
}
```

**Cursor wins** when: data changes between requests, dataset is large, or you need consistent performance. **Offset wins** when: users need "jump to page 7" and dataset is stable.

### Filtering & Sorting

```
GET /orders?status=shipped&created_after=2025-01-01&sort=-created_at,+total
```

- Filter with query params. Use `field=value` for equality, `field_gt`, `field_lt` for ranges.
- Sort with comma-separated fields, `-` prefix for descending.
- For complex filters, consider `filter` param with a mini-DSL: `?filter=status:shipped AND total>100`

---

## GraphQL Design

### Schema-First vs Code-First

| Approach | Use when |
|----------|----------|
| Schema-first (SDL) | Team contract, multiple consumers, design-first culture |
| Code-first (e.g., Nexus, TypeGraphQL) | Single team, type safety from resolver to schema |

### N+1 Problem — DataLoader Pattern

```typescript
// WITHOUT DataLoader: N+1 queries
// Query users → for each user, query orders → disaster

// WITH DataLoader: batched
const orderLoader = new DataLoader(async (userIds: string[]) => {
  const orders = await db.orders.findMany({ where: { userId: { in: userIds } } });
  return userIds.map(id => orders.filter(o => o.userId === id));
});

// Resolver
const resolvers = {
  User: {
    orders: (user) => orderLoader.load(user.id) // batched automatically
  }
};
```

### Complexity Limiting

Prevent expensive queries from killing your server:

```graphql
# This could fetch millions of rows
{ users { orders { items { product { reviews { author } } } } } }
```

Set max depth (typically 5-7) and max complexity score. Libraries: `graphql-depth-limit`, `graphql-query-complexity`.

### Federation vs Stitching

| | Federation | Stitching |
|--|------------|-----------|
| Ownership | Each service owns its types | Central gateway merges schemas |
| Runtime | Decentralized, query planning | Centralized resolver delegation |
| Use when | Microservices, team autonomy | Monolith-to-graph migration |

---

## API Security

### Authentication Pattern Selection

| Pattern | Use when | Token location |
|---------|----------|----------------|
| JWT (short-lived) | Stateless APIs, microservices | `Authorization: Bearer <token>` |
| API keys | Server-to-server, public data APIs | `X-API-Key` header |
| OAuth2 Authorization Code + PKCE | User-facing apps (SPA, mobile) | Token from auth server |
| OAuth2 Client Credentials | Machine-to-machine | Token from auth server |

**JWT checklist:** short expiry (15min), refresh token rotation, `aud`/`iss` validation, RS256 not HS256 for multi-service.

### Rate Limiting Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 42
X-RateLimit-Reset: 1709251200
Retry-After: 30
```

Use token bucket or sliding window. Apply per API key, per endpoint, and globally.

### Input Validation

Validate at the edge, before business logic. Reject early.

```typescript
// Schema validation (Zod example)
const CreateOrderSchema = z.object({
  items: z.array(z.object({
    product_id: z.string().uuid(),
    quantity: z.number().int().positive().max(1000),
  })).min(1).max(100),
  shipping_address_id: z.string().uuid(),
});
```

---

## Versioning & Evolution

### Breaking vs Non-Breaking Changes

```
NON-BREAKING (safe to deploy):        BREAKING (requires new version):
  + Add optional field                   - Remove or rename field
  + Add new endpoint                     - Change field type
  + Add optional query param             - Change URL structure
  + Widen accepted input                 - Narrow accepted input
  + Add enum value (output)              - Add required field
                                         - Change error format
```

### Deprecation Strategy

1. Mark deprecated in docs and response headers: `Deprecation: true`, `Sunset: Sat, 01 Mar 2025 00:00:00 GMT`
2. Log usage of deprecated endpoints — notify consumers directly
3. Minimum sunset period: 6 months for public APIs, 1 month for internal
4. Return `299 Warning` header during deprecation period

---

## Error Handling — RFC 7807 Problem Details

```json
{
  "type": "https://api.example.com/errors/insufficient-funds",
  "title": "Insufficient Funds",
  "status": 422,
  "detail": "Account balance is $30.00 but order total is $50.00.",
  "instance": "/orders/abc123",
  "errors": [
    { "field": "items[0].quantity", "code": "exceeds_budget", "message": "Reduce quantity or add funds" }
  ]
}
```

**Rules:**
- `type` is a URI (can be a docs link). Use `about:blank` for standard HTTP errors.
- `title` is human-readable, stable. `detail` is instance-specific.
- For validation: nest field-level errors in an `errors` array.
- For partial success (batch operations): return 207 Multi-Status with per-item results.

---

## Performance

### Caching

```
# Strong validation (exact match)
ETag: "abc123"
If-None-Match: "abc123" → 304 Not Modified

# Time-based
Cache-Control: public, max-age=3600, stale-while-revalidate=60

# Private data (never cache in shared proxy)
Cache-Control: private, no-store
```

| Data type | Strategy |
|-----------|----------|
| Static reference data | `max-age=86400` + ETag |
| User-specific data | `private` + short max-age + ETag |
| Real-time data | `no-store` or very short max-age |

### Field Selection (Sparse Fieldsets)

```
GET /users/123?fields=id,name,email          # REST
GET /users/123?fields[users]=id,name&fields[orders]=id,total  # JSON:API style
```

Reduces payload size and DB load. Essential for mobile clients.

### Batch Endpoints

```json
POST /batch
{
  "requests": [
    { "method": "GET", "path": "/users/1" },
    { "method": "GET", "path": "/users/2" }
  ]
}
```

Use when clients need multiple resources and you want to avoid N round trips. Cap batch size (50-100).

---

## Documentation — OpenAPI Best Practices

1. **Schema objects for everything** — reuse via `$ref`, don't inline
2. **Examples on every endpoint** — both request and response, including error cases
3. **Descriptions are mandatory** — every field, every parameter
4. **Use `oneOf`/`discriminator`** for polymorphic responses
5. **Generate, don't handwrite** — code-first with `@nestjs/swagger`, `FastAPI`, or `tsoa`
6. **Version your spec** — commit `openapi.yaml` alongside code, validate in CI

```yaml
# Minimal but complete — reusable schemas, examples on every endpoint, error cases
paths:
  /orders:
    post:
      summary: Create an order
      operationId: createOrder
      requestBody:
        content:
          application/json:
            schema: { $ref: '#/components/schemas/CreateOrderRequest' }
            example: { items: [{ product_id: "abc", quantity: 2 }] }
      responses:
        '201': { description: Order created, headers: { Location: { schema: { type: string } } } }
        '422': { $ref: '#/components/responses/ValidationError' }
```
