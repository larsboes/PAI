# Application Services

Orchestrate use cases, own transaction boundaries, dispatch events, and propagate errors. The glue between the outside world and the domain.

---

## Domain Service vs Application Service

| | Domain Service | Application Service |
|--|---------------|---------------------|
| **Knows about** | Domain objects only | UoW, repos, adapters, domain objects |
| **Transaction** | No — stateless logic | Yes — owns the commit boundary |
| **Imports** | Domain layer only | Domain + infrastructure abstractions |
| **Example** | `TransferService.transfer(from, to, amount)` | `PlaceOrderHandler.handle(cmd)` |
| **Purpose** | Domain logic spanning multiple aggregates | Use case orchestration |

**Rule:** If it touches a repository or controls a transaction, it's an application service.

---

## Structure

### Command Handler Pattern

One class per use case. Clear input (command), clear output (result or ID).

```python
# application/commands.py
@dataclass(frozen=True)
class PlaceOrderCommand:
    customer_id: UUID
    items: list[OrderItemDTO]

@dataclass(frozen=True)
class OrderItemDTO:
    product_id: UUID
    quantity: int
    unit_price_cents: int
    currency: str
```

```python
# application/handlers/place_order.py
class PlaceOrderHandler:
    def __init__(
        self,
        uow: AbstractUnitOfWork,
        event_bus: EventBus,
        catalog: AbstractProductCatalog,  # driven port
    ):
        self._uow = uow
        self._bus = event_bus
        self._catalog = catalog

    async def handle(self, cmd: PlaceOrderCommand) -> Result[UUID, OrderError]:
        # 1. Validate external state
        for item in cmd.items:
            if not await self._catalog.exists(item.product_id):
                return Err(OrderError.product_not_found(item.product_id))

        # 2. Execute domain logic inside transaction
        async with self._uow as uow:
            order = Order.create(cmd.customer_id)
            for item in cmd.items:
                price = Money.from_cents(item.unit_price_cents, item.currency)
                order.add_line(item.product_id, item.quantity, price)

            await uow.orders.save(order)
            await uow.commit()

        # 3. Dispatch domain events AFTER commit
        for event in order.collect_events():
            await self._bus.publish(event)

        return Ok(order.id)
```

### Key Responsibilities

1. **Receive command** — typed DTO from API/CLI/event
2. **Validate preconditions** — existence checks, authorization (not domain rules)
3. **Load aggregates** — via UoW repositories
4. **Call domain methods** — delegate business logic to the domain
5. **Persist changes** — via UoW commit
6. **Dispatch events** — after successful commit
7. **Return result** — success value or typed error

### What Application Services Do NOT Do

- Business rule validation (that's the domain's job)
- Direct SQL queries (that's the repository's job)
- HTTP/serialization concerns (that's the API layer's job)
- Retry logic or circuit breaking (that's infrastructure's job)

---

## Error Propagation: The Result Pattern

Don't throw exceptions for expected failures. Use a Result type that forces callers to handle both paths.

### Python Result Type

```python
from dataclasses import dataclass
from typing import TypeVar, Generic, Union

T = TypeVar("T")
E = TypeVar("E")

@dataclass(frozen=True)
class Ok(Generic[T]):
    value: T

    @property
    def is_ok(self) -> bool:
        return True

@dataclass(frozen=True)
class Err(Generic[E]):
    error: E

    @property
    def is_ok(self) -> bool:
        return False

Result = Union[Ok[T], Err[E]]
```

### Domain Error Types

```python
# domain/errors.py
from dataclasses import dataclass
from enum import Enum

class OrderErrorCode(Enum):
    PRODUCT_NOT_FOUND = "product_not_found"
    INSUFFICIENT_STOCK = "insufficient_stock"
    ORDER_ALREADY_PLACED = "order_already_placed"
    EMPTY_ORDER = "empty_order"

@dataclass(frozen=True)
class OrderError:
    code: OrderErrorCode
    message: str
    details: dict | None = None

    @classmethod
    def product_not_found(cls, product_id: UUID) -> "OrderError":
        return cls(
            code=OrderErrorCode.PRODUCT_NOT_FOUND,
            message=f"Product {product_id} not found",
            details={"product_id": str(product_id)},
        )

    @classmethod
    def insufficient_stock(cls, product_id: UUID, requested: int, available: int) -> "OrderError":
        return cls(
            code=OrderErrorCode.INSUFFICIENT_STOCK,
            message=f"Only {available} units available",
            details={"product_id": str(product_id), "requested": requested, "available": available},
        )
```

### API Layer Maps Result to HTTP

```python
# api/endpoints/orders.py
@router.post("/orders", status_code=201)
async def place_order(
    body: PlaceOrderRequest,
    handler: PlaceOrderHandler = Depends(get_place_order_handler),
):
    cmd = PlaceOrderCommand(
        customer_id=body.customer_id,
        items=[OrderItemDTO(**i.dict()) for i in body.items],
    )
    result = await handler.handle(cmd)

    match result:
        case Ok(order_id):
            return {"order_id": str(order_id)}
        case Err(error):
            status = ERROR_STATUS_MAP.get(error.code, 400)
            raise HTTPException(status_code=status, detail=error.message)

ERROR_STATUS_MAP = {
    OrderErrorCode.PRODUCT_NOT_FOUND: 404,
    OrderErrorCode.INSUFFICIENT_STOCK: 409,
    OrderErrorCode.ORDER_ALREADY_PLACED: 409,
    OrderErrorCode.EMPTY_ORDER: 422,
}
```

### TypeScript Result Pattern

```typescript
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };

function Ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function Err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

// Usage
class PlaceOrderHandler {
  async handle(cmd: PlaceOrderCommand): Promise<Result<string, OrderError>> {
    const order = Order.create(cmd.customerId);
    // ...
    if (!product) return Err(OrderError.productNotFound(cmd.productId));
    return Ok(order.id);
  }
}
```

---

## When to Throw vs When to Return Result

| Situation | Approach | Example |
|-----------|----------|---------|
| **Expected business failure** | Return `Err(...)` | Product not found, insufficient stock |
| **Domain invariant violation** | Throw `DomainError` | Negative quantity, invalid state transition |
| **Infrastructure failure** | Let it propagate (or wrap) | DB down, network timeout |
| **Programming error** | Throw / crash | Null where not expected, type mismatch |

**Domain invariant violations are bugs** — they mean the application service didn't check preconditions or the domain model has a hole. These should crash loudly (throw), not return a polite Result.

```python
# This is a BUG — should never happen if app service validates first
class Order:
    def add_line(self, product_id, qty, price):
        if qty <= 0:
            raise DomainError("Quantity must be positive")  # THROW — this is a bug
```

```python
# This is an expected business failure — return Result
class PlaceOrderHandler:
    async def handle(self, cmd):
        if not await self._catalog.exists(cmd.product_id):
            return Err(OrderError.product_not_found(cmd.product_id))  # RESULT — expected
```

---

## Event Dispatch Timing

### After Commit (Default)

```python
async with self._uow as uow:
    order.place()
    await uow.orders.save(order)
    await uow.commit()

# Events dispatched AFTER successful commit
for event in order.collect_events():
    await self._bus.publish(event)
```

**Why after:** If commit fails, events should not be published. Subscribers would react to something that didn't happen.

### Outbox Pattern (Reliable)

For guaranteed event delivery even if the process crashes after commit:

```python
async with self._uow as uow:
    order.place()
    await uow.orders.save(order)

    # Store events in same transaction as the aggregate
    for event in order.collect_events():
        await uow.outbox.store(event)

    await uow.commit()

# Background worker polls outbox table and publishes
# Guarantees: events are published at-least-once
```

---

## Query Services (Read Side)

Not everything is a command. For read-only operations, skip the domain model entirely — query the DB directly for DTOs.

```python
# application/queries/order_queries.py
class OrderQueryService:
    def __init__(self, read_db: ReadOnlyConnection):
        self._db = read_db

    async def get_order_summary(self, order_id: UUID) -> OrderSummaryDTO | None:
        row = await self._db.fetchone(
            "SELECT id, status, total_cents, currency, created_at "
            "FROM orders WHERE id = $1",
            [str(order_id)],
        )
        return OrderSummaryDTO(**row) if row else None

    async def list_customer_orders(
        self, customer_id: UUID, limit: int = 20
    ) -> list[OrderSummaryDTO]:
        rows = await self._db.fetchall(
            "SELECT id, status, total_cents, currency, created_at "
            "FROM orders WHERE customer_id = $1 ORDER BY created_at DESC LIMIT $2",
            [str(customer_id), limit],
        )
        return [OrderSummaryDTO(**r) for r in rows]
```

**No domain objects, no UoW, no repositories.** Reads are simple — don't force them through the aggregate machinery.

---

## Summary

```
API Layer
  ↓ Command DTO
Application Service (handler)
  ├─ Validate preconditions (existence, auth)
  ├─ Load aggregates via UoW
  ├─ Call domain methods (business logic lives HERE)
  ├─ Commit via UoW
  ├─ Dispatch events
  └─ Return Result<T, E>
  ↓
API Layer maps Result → HTTP status + body
```
