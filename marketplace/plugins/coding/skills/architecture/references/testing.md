# Testing Patterns

How to test each architectural layer — domain unit tests, application service tests with fakes, and integration tests against real infrastructure.

---

## Testing Pyramid for Clean Architecture

```
                    ┌─────────┐
                    │  E2E    │  Few — slow, fragile, high confidence
                    ├─────────┤
                 ┌──┤ Integr. ├──┐  Some — real DB, real adapters
                 │  ├─────────┤  │
              ┌──┤  │  App    │  ├──┐  Many — fakes for infra
              │  │  │ Service │  │  │
           ┌──┤  │  ├─────────┤  │  ├──┐
           │  │  │  │ Domain  │  │  │  │  Most — pure logic, zero deps
           └──┴──┴──┴─────────┴──┴──┴──┘
```

| Layer | Test Type | Dependencies | Speed | Count |
|-------|-----------|-------------|-------|-------|
| Domain | Unit | None (pure Python) | Instant | Most |
| Application | Unit + fakes | Fake repos, fake adapters | Fast | Many |
| Infrastructure | Integration | Real DB, real APIs | Slow | Some |
| API | Integration | Full stack or HTTP client | Medium | Some |
| E2E | System | Everything running | Slowest | Few |

---

## Domain Unit Tests

**Zero dependencies.** Domain objects are pure — test them directly.

### Testing Aggregates

```python
# tests/domain/test_order.py
import pytest
from domain.entities.order import Order
from domain.value_objects import Money, OrderStatus
from uuid import uuid4

class TestOrder:
    def test_create_order(self):
        order = Order.create(customer_id=uuid4())
        assert order.status == OrderStatus.DRAFT
        assert order.total == Money.zero("USD")
        assert len(order.lines) == 0

    def test_add_line(self):
        order = Order.create(customer_id=uuid4())
        order.add_line(
            product_id=uuid4(),
            qty=2,
            price=Money.from_cents(1500, "USD"),
        )
        assert len(order.lines) == 1
        assert order.total == Money.from_cents(3000, "USD")

    def test_cannot_add_line_to_placed_order(self):
        order = Order.create(customer_id=uuid4())
        order.add_line(uuid4(), 1, Money.from_cents(1000, "USD"))
        order.place()

        with pytest.raises(DomainError, match="Cannot modify placed order"):
            order.add_line(uuid4(), 1, Money.from_cents(500, "USD"))

    def test_place_emits_event(self):
        order = Order.create(customer_id=uuid4())
        order.add_line(uuid4(), 1, Money.from_cents(1000, "USD"))
        order.place()

        events = order.collect_events()
        assert len(events) == 1
        assert isinstance(events[0], OrderPlaced)
        assert events[0].order_id == order.id
```

### Testing Value Objects

```python
# tests/domain/test_value_objects.py
class TestMoney:
    def test_add_same_currency(self):
        a = Money.from_cents(1000, "USD")
        b = Money.from_cents(500, "USD")
        assert a.add(b) == Money.from_cents(1500, "USD")

    def test_cannot_add_different_currencies(self):
        usd = Money.from_cents(1000, "USD")
        eur = Money.from_cents(500, "EUR")
        with pytest.raises(DomainError, match="different currencies"):
            usd.add(eur)

    def test_cannot_be_negative(self):
        with pytest.raises(ValueError):
            Money.from_cents(-100, "USD")

    def test_structural_equality(self):
        a = Money.from_cents(1000, "USD")
        b = Money.from_cents(1000, "USD")
        assert a == b  # same value = same object

class TestEmail:
    @pytest.mark.parametrize("invalid", ["", "no-at", "no@dot", "@missing.com"])
    def test_rejects_invalid(self, invalid):
        with pytest.raises(ValueError):
            Email(invalid)

    def test_accepts_valid(self):
        email = Email("user@example.com")
        assert email.value == "user@example.com"
```

### Testing Domain Services

```python
class TestTransferService:
    def test_successful_transfer(self):
        source = Account.create(balance=Money.from_cents(10000, "USD"))
        target = Account.create(balance=Money.from_cents(0, "USD"))

        TransferService().transfer(source, target, Money.from_cents(3000, "USD"))

        assert source.balance == Money.from_cents(7000, "USD")
        assert target.balance == Money.from_cents(3000, "USD")

    def test_insufficient_funds(self):
        source = Account.create(balance=Money.from_cents(1000, "USD"))
        target = Account.create(balance=Money.from_cents(0, "USD"))

        with pytest.raises(InsufficientFunds):
            TransferService().transfer(source, target, Money.from_cents(5000, "USD"))
```

---

## Application Service Tests (Fakes)

Use **fakes** (in-memory implementations), not mocks. Fakes implement the real interface, so they catch interface changes. Mocks don't.

### In-Memory Repository (Fake)

```python
# tests/fakes.py
class FakeOrderRepository(OrderRepository):
    def __init__(self):
        self._store: dict[UUID, Order] = {}

    async def get(self, order_id: UUID) -> Order:
        if order_id not in self._store:
            raise OrderNotFound(order_id)
        return self._store[order_id]

    async def save(self, order: Order) -> None:
        self._store[order.id] = order

    async def find_by_customer(self, customer_id: UUID) -> list[Order]:
        return [o for o in self._store.values() if o.customer_id == customer_id]
```

### Fake Unit of Work

```python
class FakeUnitOfWork(AbstractUnitOfWork):
    def __init__(self):
        self.orders = FakeOrderRepository()
        self.customers = FakeCustomerRepository()
        self.committed = False

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        pass

    async def commit(self):
        self.committed = True

    async def rollback(self):
        pass
```

### Testing Application Service

```python
# tests/application/test_place_order.py
class TestPlaceOrderHandler:
    @pytest.fixture
    def uow(self):
        uow = FakeUnitOfWork()
        # Seed test data
        customer = Customer.create(name="Test")
        uow.customers._store[customer.id] = customer
        return uow, customer

    @pytest.fixture
    def handler(self, uow):
        uow, _ = uow
        catalog = FakeProductCatalog(products=[WIDGET, GADGET])
        bus = FakeEventBus()
        return PlaceOrderHandler(uow=uow, event_bus=bus, catalog=catalog), uow, bus

    async def test_places_order_successfully(self, handler, uow):
        handler, uow, bus = handler
        _, customer = uow

        cmd = PlaceOrderCommand(
            customer_id=customer.id,
            items=[OrderItemDTO(WIDGET.id, 2, 1500, "USD")],
        )
        result = await handler.handle(cmd)

        assert result.is_ok
        order = await uow.orders.get(result.value)
        assert order.status == OrderStatus.PLACED
        assert len(order.lines) == 1
        assert uow.committed

    async def test_returns_error_for_unknown_product(self, handler):
        handler, uow, bus = handler

        cmd = PlaceOrderCommand(
            customer_id=uuid4(),
            items=[OrderItemDTO(uuid4(), 1, 1000, "USD")],  # unknown product
        )
        result = await handler.handle(cmd)

        assert not result.is_ok
        assert result.error.code == OrderErrorCode.PRODUCT_NOT_FOUND
        assert not uow.committed

    async def test_dispatches_order_placed_event(self, handler, uow):
        handler, uow, bus = handler
        _, customer = uow

        cmd = PlaceOrderCommand(
            customer_id=customer.id,
            items=[OrderItemDTO(WIDGET.id, 1, 1000, "USD")],
        )
        await handler.handle(cmd)

        assert len(bus.published) == 1
        assert isinstance(bus.published[0], OrderPlaced)
```

### Why Fakes, Not Mocks

```python
# FAKES (preferred) — implement the interface
class FakeOrderRepository(OrderRepository):
    async def save(self, order: Order) -> None:
        self._store[order.id] = order
# If OrderRepository interface changes, FakeOrderRepository breaks at compile/lint time

# MOCKS (avoid) — assert calls were made
mock_repo = AsyncMock(spec=OrderRepository)
# ...
mock_repo.save.assert_called_once_with(order)
# Doesn't verify behavior, just that a method was called
# Doesn't break when interface changes (mock doesn't implement it)
```

**Mocks test implementation details. Fakes test behavior.**

Use mocks only for:
- External services you can't fake easily (email, SMS)
- Verifying side effects that don't change state (logging, metrics)

---

## Infrastructure Integration Tests

Test real DB, real file systems, real external clients. Use containers (testcontainers) or test databases.

### Repository Integration Test

```python
# tests/infrastructure/test_order_repository.py
import pytest
from testcontainers.postgres import PostgresContainer

@pytest.fixture(scope="session")
def pg():
    with PostgresContainer("postgres:16") as pg:
        yield pg

@pytest.fixture
async def session(pg):
    engine = create_async_engine(pg.get_connection_url())
    async with engine.begin() as conn:
        await conn.run_sync(metadata.create_all)
    async with async_sessionmaker(engine)() as session:
        yield session
        await session.rollback()  # clean up after each test

class TestSqlAlchemyOrderRepository:
    async def test_save_and_load(self, session):
        repo = SqlAlchemyOrderRepository(session)

        order = Order.create(customer_id=uuid4())
        order.add_line(uuid4(), 2, Money.from_cents(1500, "USD"))
        await repo.save(order)
        await session.flush()

        loaded = await repo.get(order.id)
        assert loaded.id == order.id
        assert len(loaded.lines) == 1
        assert loaded.total == Money.from_cents(3000, "USD")

    async def test_not_found_raises(self, session):
        repo = SqlAlchemyOrderRepository(session)
        with pytest.raises(OrderNotFound):
            await repo.get(uuid4())
```

### What to Test in Integration

| Test | Why |
|------|-----|
| Save + load roundtrip | Mapping is correct (domain ↔ DB) |
| Value object mapping | Money, Email survive persistence |
| Collection mapping | Child entities load correctly |
| Query methods | Filters, ordering, pagination work |
| Concurrent writes | Optimistic locking triggers correctly |
| Not found | Raises domain exception, not ORM exception |

---

## TypeScript Testing Patterns

### Domain (Vitest/Jest)

```typescript
describe("Order", () => {
  it("calculates total from lines", () => {
    const order = Order.create(customerId);
    order.addLine(productId, 2, Money.create(1500, "USD"));

    expect(order.total.equals(Money.create(3000, "USD"))).toBe(true);
  });

  it("rejects modification after placement", () => {
    const order = Order.create(customerId);
    order.addLine(productId, 1, Money.create(1000, "USD"));
    order.place();

    expect(() => order.addLine(productId, 1, Money.create(500, "USD")))
      .toThrow("Cannot modify placed order");
  });
});
```

### Fakes (TypeScript)

```typescript
class FakeOrderRepository implements OrderRepository {
  private store = new Map<string, Order>();

  async get(id: string): Promise<Order> {
    const order = this.store.get(id);
    if (!order) throw new OrderNotFound(id);
    return order;
  }

  async save(order: Order): Promise<void> {
    this.store.set(order.id, order);
  }
}
```

---

## Test Organization

```
tests/
  domain/                    # Pure unit tests, no deps
    test_order.py
    test_value_objects.py
    test_transfer_service.py
  application/               # Fakes for infra
    test_place_order.py
    test_cancel_order.py
  infrastructure/            # Real DB (testcontainers)
    test_order_repository.py
    test_customer_repository.py
  api/                       # HTTP client tests
    test_order_endpoints.py
  fakes.py                   # Shared fake implementations
  factories.py               # Test data builders
  conftest.py                # Shared fixtures
```

### Test Data Builders

Don't construct domain objects inline everywhere. Use builders:

```python
# tests/factories.py
class OrderFactory:
    @staticmethod
    def draft(
        customer_id: UUID | None = None,
        lines: int = 1,
        price_cents: int = 1000,
    ) -> Order:
        order = Order.create(customer_id or uuid4())
        for _ in range(lines):
            order.add_line(uuid4(), 1, Money.from_cents(price_cents, "USD"))
        return order

    @staticmethod
    def placed(**kwargs) -> Order:
        order = OrderFactory.draft(**kwargs)
        order.place()
        return order

# Usage
order = OrderFactory.placed(lines=3, price_cents=2500)
```

---

## Summary

| Layer | Test with | Assert on |
|-------|-----------|-----------|
| Value objects | Direct construction | Validation, equality, immutability |
| Entities | Direct methods | State changes, invariant enforcement |
| Aggregates | Direct methods | Events emitted, child state, invariants |
| Domain services | Domain objects as args | Correct state mutations |
| App services | Fakes for all ports | Result values, committed flag, events published |
| Repositories | Real DB (testcontainers) | Roundtrip fidelity, query correctness |
| API | HTTP client | Status codes, response shape |
