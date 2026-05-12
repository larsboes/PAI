# Aggregate Design

How to decide what goes inside an aggregate, how to size them, and how to coordinate across aggregate boundaries. This is the hardest part of DDD — getting boundaries wrong causes cascading pain.

---

## The Fundamental Question

> "Should X be inside Aggregate A, or its own aggregate referenced by ID?"

The answer depends on **consistency requirements**, not data relationships.

```
Inside the aggregate  = MUST be consistent in the same transaction
Separate aggregate    = CAN be eventually consistent
```

If you can tolerate a brief moment where Order is saved but Inventory isn't yet updated — they're separate aggregates. If Order and OrderLines must always be consistent together — they're one aggregate.

---

## Decision Framework

For each candidate entity, ask these four questions in order:

### 1. True Invariant?

> "Does a business rule require X and Y to be consistent in the **same transaction**?"

```
Order + OrderLines: YES — "order total must equal sum of lines" is a true invariant
Order + Customer:   NO  — order doesn't break if customer changes name later
Order + Inventory:  NO  — can be eventually consistent via events
```

**If NO → separate aggregate, reference by ID. Stop here.**

### 2. Contention Risk?

> "Will multiple users/processes modify X and Y concurrently?"

```
ShoppingCart + CartItems: Low contention (one user per cart) → OK inside
Product + AllReviews:     High contention (many users adding reviews) → SEPARATE
Warehouse + AllOrders:    High contention → SEPARATE
```

**Large aggregates = serialization bottleneck.** Every write locks the entire aggregate.

### 3. Lifecycle Coupling?

> "Are X and Y created, modified, and deleted together?"

```
Invoice + InvoiceLines:   Same lifecycle → one aggregate
User + UserPreferences:   Same lifecycle → one aggregate (or embedded)
User + Orders:            Different lifecycles → separate aggregates
```

### 4. Size Check

> "How many child entities will this aggregate have?"

```
Order + OrderLines (5-50 lines):     Fine
Forum + AllPosts (10K+ posts):       WAY too big
Account + Transactions (unbounded):  WAY too big
```

**Rule of thumb:** If a child collection can grow unbounded or past ~100 items, it must be a separate aggregate.

---

## Common Aggregate Boundaries

### Correct

```
┌─────────────────────┐     ┌─────────────────┐
│ Order (root)        │     │ Customer (root)  │
│  ├─ OrderLine       │────▶│  ├─ Address (VO) │
│  ├─ OrderLine       │ ID  │  └─ Email (VO)   │
│  └─ ShippingAddress │     └─────────────────┘
│     (value object)  │
└─────────────────────┘
         │ ID
         ▼
┌─────────────────────┐
│ Product (root)      │
│  ├─ Price (VO)      │
│  └─ Dimensions (VO) │
└─────────────────────┘
```

- Order holds OrderLines (true invariant: total = sum of lines)
- Order references Customer by ID (no invariant between them)
- Order references Product by ID (product can change independently)
- ShippingAddress is a value object (copied at order time, not a reference)

### Wrong

```
┌─────────────────────────────────┐
│ Order (root)                    │
│  ├─ OrderLine                   │
│  ├─ Customer ← WRONG (full obj)│
│  ├─ Product  ← WRONG (full obj)│
│  ├─ Payment  ← WRONG (separate)│
│  └─ Shipment ← WRONG (separate)│
└─────────────────────────────────┘
```

Problems:
- Customer inside Order → loading an order loads the customer → coupling
- Product inside Order → changing product description changes the order?
- Payment as child → different consistency needs, different lifecycle
- Shipment as child → managed by different bounded context

---

## Cross-Aggregate Coordination

When a use case spans multiple aggregates, you have three options:

### Option 1: Domain Events (Preferred)

```python
# Order aggregate publishes event
class Order:
    def place(self) -> None:
        self._status = OrderStatus.PLACED
        self._events.append(OrderPlaced(
            order_id=self.id,
            items=[(l.product_id, l.quantity) for l in self._lines],
        ))

# Inventory aggregate handles event (separate transaction)
@event_handler(OrderPlaced)
async def reserve_inventory(event: OrderPlaced, uow: AbstractUnitOfWork):
    async with uow:
        for product_id, qty in event.items:
            product = await uow.products.get(product_id)
            product.reserve(qty)
        await uow.commit()
```

**Consistency:** Eventual. Order is saved first, inventory reserved async.
**Failure mode:** If inventory reservation fails, publish `InventoryReservationFailed` → Order handles compensation.

### Option 2: Application Service Orchestration

```python
# When you need both aggregates in the same transaction (rare, be suspicious)
class PlaceOrderHandler:
    async def handle(self, cmd: PlaceOrderCommand) -> UUID:
        async with self._uow as uow:
            order = Order.create(cmd.customer_id)
            for item in cmd.items:
                # Check inventory BEFORE adding to order
                product = await uow.products.get(item.product_id)
                if not product.has_stock(item.qty):
                    raise InsufficientStock(item.product_id)
                order.add_line(item.product_id, item.qty, item.price)
            await uow.orders.save(order)
            await uow.commit()
            return order.id
        # Note: we READ product but didn't MODIFY it
        # Inventory reservation happens via domain event
```

### Option 3: Saga / Process Manager

For long-running processes that span many aggregates and may need compensation:

```
OrderPlaced → ReserveInventory → ProcessPayment → ArrangeShipping
                    ↓ fail              ↓ fail
              ReleaseInventory    RefundPayment + ReleaseInventory
```

```python
class OrderFulfillmentSaga:
    """Coordinates multi-aggregate workflow with compensation."""

    async def handle_order_placed(self, event: OrderPlaced):
        self._state = SagaState.RESERVING_INVENTORY
        await self._command_bus.send(ReserveInventory(event.order_id, event.items))

    async def handle_inventory_reserved(self, event: InventoryReserved):
        self._state = SagaState.PROCESSING_PAYMENT
        await self._command_bus.send(ProcessPayment(self._order_id, self._total))

    async def handle_payment_failed(self, event: PaymentFailed):
        # Compensate: release the inventory we reserved
        self._state = SagaState.COMPENSATING
        await self._command_bus.send(ReleaseInventory(self._order_id))
```

### When to Use Which

| Approach | Consistency | Complexity | Use When |
|----------|------------|------------|----------|
| Domain events | Eventual | Low | Default. Most cross-aggregate coordination. |
| App service orchestration | Same transaction (read), eventual (write) | Medium | Need to validate across aggregates before committing |
| Saga | Eventual + compensation | High | Long-running, multi-step, needs rollback |

---

## Red Flags: Your Aggregate Is Too Big

1. **Loading is slow** — too many child entities loaded eagerly
2. **Concurrent modification errors** — multiple users hitting the same aggregate
3. **God aggregate** — one aggregate that everything references and modifies
4. **Unbounded collections** — `order.all_audit_events` grows forever
5. **Cross-concern coupling** — aggregate handles pricing AND shipping AND notifications

### Fix: Extract to Separate Aggregate

Before:
```python
class Product:
    # ... product data ...
    _reviews: list[Review]          # unbounded, high contention
    _price_history: list[PriceLog]  # different lifecycle
```

After:
```python
class Product:
    # ... product data ...
    # Reviews and price history are separate aggregates

class Review:                       # own aggregate
    product_id: ProductId           # ID reference back
    author_id: UserId
    rating: int
    text: str

class PriceLog:                     # own aggregate
    product_id: ProductId
    price: Money
    effective_from: datetime
```

---

## Red Flags: Your Aggregate Is Too Small

1. **Every operation requires loading 3+ aggregates** — boundaries are too fragmented
2. **You constantly need two-phase commits** — you split things that must be consistent
3. **Domain events everywhere for what should be simple operations** — over-decomposed

### Fix: Merge Back

If OrderLine is its own aggregate but you constantly need `order.total == sum(lines)` as a transactional invariant — OrderLine belongs inside Order.

---

## Summary Heuristic

```
Start with SMALL aggregates (just the root entity).
Add children ONLY when you find a true transactional invariant.
Extract children when you find contention or unbounded growth.
Connect aggregates by ID, coordinate via domain events.
```
