# Persistence Mapping

How to map rich domain objects to flat database rows without polluting the domain layer. Covers imperative mapping, Unit of Work, and common persistence recipes.

---

## The Core Problem

Domain objects are designed for behavior (invariants, encapsulation, value objects). Database rows are designed for storage (flat columns, foreign keys, indexes). These shapes don't match — you need a translation layer.

```
Domain World                    Database World
─────────────                   ──────────────
Order (aggregate root)    →     orders (table)
  OrderLine (entity)      →     order_lines (table, FK to orders)
  Money (value object)    →     amount_cents INT + currency VARCHAR
  OrderStatus (enum)      →     status VARCHAR
  CustomerId (typed ID)   →     customer_id UUID
```

**Rule:** The domain layer must not know about persistence. The mapping lives in infrastructure.

---

## Approach 1: Imperative Mapping (SQLAlchemy)

Domain classes are pure Python. Mapping is configured separately — the domain never imports SQLAlchemy.

### Step 1: Pure Domain Model

```python
# domain/entities/order.py — NO SQLAlchemy imports
from dataclasses import dataclass, field
from uuid import UUID, uuid4
from datetime import datetime
from domain.value_objects import Money, OrderStatus

@dataclass
class OrderLine:
    product_id: UUID
    quantity: int
    unit_price: Money

    @property
    def subtotal(self) -> Money:
        return self.unit_price.multiply(self.quantity)

class Order:
    def __init__(self, id: UUID, customer_id: UUID):
        self.id = id
        self.customer_id = customer_id
        self._lines: list[OrderLine] = []
        self._status = OrderStatus.DRAFT
        self._created_at = datetime.utcnow()

    def add_line(self, product_id: UUID, qty: int, price: Money) -> None:
        if self._status != OrderStatus.DRAFT:
            raise DomainError("Cannot modify placed order")
        self._lines.append(OrderLine(product_id, qty, price))

    @property
    def total(self) -> Money:
        return sum((l.subtotal for l in self._lines), Money.zero("USD"))

    @property
    def lines(self) -> tuple[OrderLine, ...]:
        return tuple(self._lines)  # expose immutable view

    @property
    def status(self) -> OrderStatus:
        return self._status
```

### Step 2: SQLAlchemy Table Definitions (no models)

```python
# infrastructure/persistence/tables.py
from sqlalchemy import Table, Column, Integer, String, DateTime, ForeignKey, Numeric
from sqlalchemy import MetaData

metadata = MetaData()

orders_table = Table(
    "orders", metadata,
    Column("id", String(36), primary_key=True),
    Column("customer_id", String(36), nullable=False),
    Column("status", String(20), nullable=False),
    Column("amount_cents", Integer, nullable=False),
    Column("currency", String(3), nullable=False),
    Column("created_at", DateTime, nullable=False),
)

order_lines_table = Table(
    "order_lines", metadata,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("order_id", String(36), ForeignKey("orders.id"), nullable=False),
    Column("product_id", String(36), nullable=False),
    Column("quantity", Integer, nullable=False),
    Column("unit_price_cents", Integer, nullable=False),
    Column("currency", String(3), nullable=False),
)
```

### Step 3: Imperative Mapping

```python
# infrastructure/persistence/mappings.py
from sqlalchemy.orm import registry, relationship, composite
from domain.entities.order import Order, OrderLine
from domain.value_objects import Money
from infrastructure.persistence.tables import orders_table, order_lines_table

mapper_registry = registry()

def start_mappers():
    """Call once at app startup. Maps domain classes to tables."""
    order_lines_mapper = mapper_registry.map_imperatively(
        OrderLine,
        order_lines_table,
        properties={
            "unit_price": composite(
                Money.from_db,
                order_lines_table.c.unit_price_cents,
                order_lines_table.c.currency,
            ),
        },
    )

    mapper_registry.map_imperatively(
        Order,
        orders_table,
        properties={
            "_lines": relationship(
                order_lines_mapper.entity,
                collection_class=list,
                cascade="all, delete-orphan",
                lazy="joined",
            ),
            "_status": orders_table.c.status,
            "_created_at": orders_table.c.created_at,
        },
    )
```

### Key Points

- `map_imperatively()` replaces the old `classical_mapping`. It's the 2.0 API.
- `composite()` maps value objects that span multiple columns (Money -> cents + currency).
- Private attributes (`_lines`, `_status`) can be mapped directly — SQLAlchemy sets them via the mapper, bypassing `__init__`.
- `start_mappers()` is called once at application boot, before any queries.
- Domain classes remain completely free of ORM imports.

---

## Approach 2: Separate ORM Models + Manual Mapping

When imperative mapping is too magical or you need more control.

### ORM Models (infrastructure only)

```python
# infrastructure/persistence/models.py
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

class Base(DeclarativeBase):
    pass

class OrderModel(Base):
    __tablename__ = "orders"
    id: Mapped[str] = mapped_column(primary_key=True)
    customer_id: Mapped[str]
    status: Mapped[str]
    amount_cents: Mapped[int]
    currency: Mapped[str]
    created_at: Mapped[datetime]
    lines: Mapped[list["OrderLineModel"]] = relationship(cascade="all, delete-orphan")

class OrderLineModel(Base):
    __tablename__ = "order_lines"
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    order_id: Mapped[str] = mapped_column(ForeignKey("orders.id"))
    product_id: Mapped[str]
    quantity: Mapped[int]
    unit_price_cents: Mapped[int]
    currency: Mapped[str]
```

### Repository with Manual Mapping

```python
# infrastructure/persistence/repositories.py
class SqlAlchemyOrderRepository(OrderRepository):
    def __init__(self, session: AsyncSession):
        self._session = session

    async def get(self, order_id: UUID) -> Order:
        model = await self._session.get(OrderModel, str(order_id))
        if not model:
            raise OrderNotFound(order_id)
        return self._to_domain(model)

    async def save(self, order: Order) -> None:
        model = self._to_model(order)
        await self._session.merge(model)
        await self._session.flush()  # NOT commit — UoW owns transaction

    # --- Mapping methods ---

    def _to_domain(self, model: OrderModel) -> Order:
        order = Order.__new__(Order)  # bypass __init__
        order.id = UUID(model.id)
        order.customer_id = UUID(model.customer_id)
        order._status = OrderStatus(model.status)
        order._created_at = model.created_at
        order._lines = [
            self._line_to_domain(line) for line in model.lines
        ]
        return order

    def _to_model(self, order: Order) -> OrderModel:
        return OrderModel(
            id=str(order.id),
            customer_id=str(order.customer_id),
            status=order.status.value,
            amount_cents=order.total.amount_cents,
            currency=order.total.currency,
            created_at=order._created_at,
            lines=[self._line_to_model(l) for l in order.lines],
        )

    def _line_to_domain(self, model: OrderLineModel) -> OrderLine:
        return OrderLine(
            product_id=UUID(model.product_id),
            quantity=model.quantity,
            unit_price=Money.from_cents(model.unit_price_cents, model.currency),
        )

    def _line_to_model(self, line: OrderLine) -> OrderLineModel:
        return OrderLineModel(
            product_id=str(line.product_id),
            quantity=line.quantity,
            unit_price_cents=line.unit_price.amount_cents,
            currency=line.unit_price.currency,
        )
```

### When to Use Which

| Approach | Pros | Cons |
|----------|------|------|
| Imperative mapping | Zero manual mapping code, domain classes are the entities | More complex setup, harder to debug, composite() has limits |
| Separate models | Explicit, easy to debug, full control over mapping | Boilerplate `_to_domain` / `_to_model` methods |

**Default choice:** Start with separate models + manual mapping. Switch to imperative when the boilerplate becomes painful (10+ entities).

---

## TypeScript: Persistence Mapping

### Prisma + Manual Mapping

```typescript
// infrastructure/repositories/OrderRepository.ts
import { PrismaClient } from "@prisma/client";
import { Order } from "../../domain/entities/Order";
import { OrderLine } from "../../domain/entities/OrderLine";
import { Money } from "../../domain/value-objects/Money";

export class PrismaOrderRepository implements OrderRepository {
  constructor(private prisma: PrismaClient) {}

  async get(id: string): Promise<Order> {
    const row = await this.prisma.order.findUniqueOrThrow({
      where: { id },
      include: { lines: true },
    });
    return this.toDomain(row);
  }

  async save(order: Order): Promise<void> {
    await this.prisma.order.upsert({
      where: { id: order.id },
      create: this.toModel(order),
      update: this.toModel(order),
    });
  }

  private toDomain(row: any): Order {
    return Order.reconstitute({
      id: row.id,
      customerId: row.customerId,
      status: row.status,
      lines: row.lines.map((l: any) => OrderLine.reconstitute({
        productId: l.productId,
        quantity: l.quantity,
        unitPrice: Money.fromCents(l.unitPriceCents, l.currency),
      })),
    });
  }

  private toModel(order: Order) {
    return {
      id: order.id,
      customerId: order.customerId,
      status: order.status,
      amountCents: order.total.amountCents,
      currency: order.total.currency,
      lines: {
        create: order.lines.map(l => ({
          productId: l.productId,
          quantity: l.quantity,
          unitPriceCents: l.unitPrice.amountCents,
          currency: l.unitPrice.currency,
        })),
      },
    };
  }
}
```

### Domain Reconstitution Pattern

Domain entities use `create()` for new instances (with validation) and `reconstitute()` for loading from DB (skip validation — data was valid when stored):

```typescript
class Order {
  private constructor(/* ... */) {}

  // New instance — full validation
  static create(customerId: string): Order { /* validates, sets defaults */ }

  // From DB — trusted data, skip validation
  static reconstitute(data: OrderData): Order {
    const order = new Order();
    order.id = data.id;
    order._lines = data.lines;
    order._status = data.status;
    return order;
  }
}
```

---

## Unit of Work

The UoW controls the transaction boundary. Repositories do `flush()` (write to DB buffer), UoW does `commit()` (make it permanent) or `rollback()`.

### Abstract UoW

```python
# domain/unit_of_work.py
from abc import ABC, abstractmethod

class AbstractUnitOfWork(ABC):
    orders: OrderRepository
    customers: CustomerRepository

    async def __aenter__(self) -> "AbstractUnitOfWork":
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if exc_type:
            await self.rollback()

    @abstractmethod
    async def commit(self) -> None: ...

    @abstractmethod
    async def rollback(self) -> None: ...
```

### SQLAlchemy Implementation

```python
# infrastructure/persistence/unit_of_work.py
class SqlAlchemyUnitOfWork(AbstractUnitOfWork):
    def __init__(self, session_factory: async_sessionmaker):
        self._session_factory = session_factory

    async def __aenter__(self):
        self._session = self._session_factory()
        self.orders = SqlAlchemyOrderRepository(self._session)
        self.customers = SqlAlchemyCustomerRepository(self._session)
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if exc_type:
            await self._session.rollback()
        await self._session.close()

    async def commit(self):
        await self._session.commit()

    async def rollback(self):
        await self._session.rollback()
```

### Usage in Application Service

```python
class PlaceOrderHandler:
    def __init__(self, uow: AbstractUnitOfWork):
        self._uow = uow

    async def handle(self, cmd: PlaceOrderCommand) -> UUID:
        async with self._uow as uow:
            customer = await uow.customers.get(cmd.customer_id)
            order = Order.create(customer.id)
            for item in cmd.items:
                order.add_line(item.product_id, item.qty, item.price)
            await uow.orders.save(order)
            await uow.commit()  # single transaction for the entire use case
            return order.id
```

---

## Common Persistence Recipes

### Value Object -> Multiple Columns

```python
# Money -> amount_cents (int) + currency (varchar)
class Money:
    def __init__(self, amount_cents: int, currency: str):
        self.amount_cents = amount_cents
        self.currency = currency

    @classmethod
    def from_db(cls, cents: int, currency: str) -> "Money":
        return cls(cents, currency)

# In imperative mapping:
composite(Money.from_db, table.c.amount_cents, table.c.currency)

# In manual mapping:
money = Money.from_cents(model.amount_cents, model.currency)
```

### Enum -> String Column

```python
# Domain
class OrderStatus(str, Enum):
    DRAFT = "draft"
    PLACED = "placed"
    SHIPPED = "shipped"

# To DB: order.status.value -> "draft"
# From DB: OrderStatus(model.status) -> OrderStatus.DRAFT
```

### Typed ID -> String/UUID Column

```python
# Domain
@dataclass(frozen=True)
class OrderId:
    value: UUID

    @classmethod
    def generate(cls) -> "OrderId":
        return cls(uuid4())

# To DB: str(order.id.value) -> "550e8400-..."
# From DB: OrderId(UUID(model.id)) -> OrderId(UUID("550e8400-..."))
```

### Collection (1:N) -> Child Table

```python
# Imperative mapping handles this via relationship()
# Manual mapping: iterate and map each child

# To DB:
lines = [self._line_to_model(l) for l in order.lines]

# From DB:
order._lines = [self._line_to_domain(l) for l in model.lines]
```

### Polymorphic Entities -> Single Table or Joined Table

```python
# Single Table Inheritance (simple, wastes some columns)
# All types in one table with a discriminator column
payments_table = Table("payments", metadata,
    Column("type", String(20)),  # discriminator: "card", "bank", "crypto"
    Column("card_last_four", String(4), nullable=True),   # card only
    Column("bank_account", String(34), nullable=True),     # bank only
    Column("wallet_address", String(64), nullable=True),   # crypto only
)

# Joined Table Inheritance (normalized, more joins)
# Base table + one table per subtype
```

### Optimistic Locking

```python
# Add version column
orders_table = Table("orders", metadata,
    # ...
    Column("version", Integer, nullable=False, default=1),
)

# In repository save:
async def save(self, order: Order) -> None:
    result = await self._session.execute(
        orders_table.update()
        .where(orders_table.c.id == str(order.id))
        .where(orders_table.c.version == order.version)  # check version
        .values(version=order.version + 1, **self._to_row(order))
    )
    if result.rowcount == 0:
        raise ConcurrentModificationError(order.id)
```

### Soft Deletes

```python
# Add deleted_at column, never physically delete
orders_table = Table("orders", metadata,
    # ...
    Column("deleted_at", DateTime, nullable=True),
)

# Repository always filters:
async def get(self, order_id: UUID) -> Order:
    result = await self._session.execute(
        select(orders_table)
        .where(orders_table.c.id == str(order_id))
        .where(orders_table.c.deleted_at.is_(None))
    )
```

---

## Decision Guide

| Question | Answer |
|----------|--------|
| Which mapping approach? | Manual by default, imperative when 10+ entities |
| Where do mapping methods live? | In the repository (infrastructure layer) |
| Who controls transactions? | Unit of Work, never repositories |
| How to handle value objects? | `composite()` (imperative) or manual `from_cents`/`to_cents` |
| How to load aggregates? | Eager-load children (`lazy="joined"`), never lazy-load across aggregate boundaries |
| How to handle concurrent writes? | Optimistic locking with version column |
