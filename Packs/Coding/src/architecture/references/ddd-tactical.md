# DDD Tactical Patterns

Practical reference for Domain-Driven Design building blocks. These are the implementation patterns that live *inside* a bounded context.

---

## Quick Decision Tree: Where Does This Logic Go?

```
Does it need identity tracking over time?
  YES -> Entity
  NO  -> Does it represent a measurement, quantity, or descriptor?
           YES -> Value Object
           NO  -> Does it coordinate multiple aggregates?
                    YES -> Domain Service (stateless)
                    NO  -> Does it orchestrate use-case flow (transactions, auth, events)?
                             YES -> Application Service
                             NO  -> It's probably an Entity method on the owning Aggregate
```

---

## Aggregates

An aggregate is a cluster of entities and value objects treated as a single unit for data changes. The **aggregate root** is the only entry point.

### Rules

1. **Reference other aggregates by ID only** — never hold object references across aggregate boundaries
2. **One aggregate per transaction** — if you need to update two aggregates, use domain events
3. **Keep aggregates small** — large aggregates cause contention and performance issues
4. **Protect invariants** — the root enforces all business rules for the cluster

### Do / Don't

```python
# DO: Reference by ID, enforce invariants through root
class Order:
    def __init__(self, order_id: OrderId, customer_id: CustomerId):
        self.id = order_id
        self.customer_id = customer_id  # ID reference, not Customer object
        self._lines: list[OrderLine] = []
        self._status = OrderStatus.DRAFT

    def add_line(self, product_id: ProductId, qty: Quantity, price: Money) -> None:
        if self._status != OrderStatus.DRAFT:
            raise DomainError("Cannot modify a submitted order")
        if qty.value <= 0:
            raise DomainError("Quantity must be positive")
        self._lines.append(OrderLine(product_id, qty, price))

    @property
    def total(self) -> Money:
        return sum((line.subtotal for line in self._lines), Money.zero("USD"))
```

```python
# DON'T: Holding full object references, no invariant protection
class Order:
    def __init__(self):
        self.customer: Customer = None   # full object reference - coupling!
        self.lines: list[OrderLine] = [] # public list - anyone can mutate
        self.status = "draft"            # primitive string - no safety
```

### TypeScript Example

```typescript
class Order {
  private lines: OrderLine[] = [];
  private status: OrderStatus = OrderStatus.DRAFT;

  constructor(
    readonly id: OrderId,
    readonly customerId: CustomerId  // ID reference only
  ) {}

  addLine(productId: ProductId, qty: Quantity, price: Money): void {
    if (this.status !== OrderStatus.DRAFT) {
      throw new DomainError("Cannot modify a submitted order");
    }
    this.lines.push(new OrderLine(productId, qty, price));
  }
}
```

---

## Entities

Objects defined by **identity**, not attributes. Two entities with the same data but different IDs are different objects.

### Key Traits
- Has a unique identity that persists across state changes
- Mutable state (unlike value objects)
- Equality based on ID, not field values

```python
class Patient:
    def __init__(self, patient_id: PatientId, name: str):
        self.id = patient_id
        self._name = name
        self._allergies: list[Allergy] = []

    def record_allergy(self, allergy: Allergy) -> None:
        if allergy in self._allergies:
            return  # idempotent
        self._allergies.append(allergy)

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Patient) and self.id == other.id

    def __hash__(self) -> int:
        return hash(self.id)
```

---

## Value Objects

Immutable objects defined by their **attributes**, not identity. Two value objects with the same data *are* the same thing.

### When to Use
Anywhere you see a primitive that carries domain meaning: Money, Email, Address, DateRange, Temperature, Coordinates, Quantity.

### Rules
1. **Immutable** — no setters, return new instances
2. **Self-validating** — invalid state is impossible
3. **Structural equality** — compared by fields, not reference
4. **Side-effect free** — methods return new values

### Python

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: str

    def __post_init__(self):
        if self.amount < 0:
            raise ValueError("Money cannot be negative")
        if len(self.currency) != 3:
            raise ValueError("Currency must be ISO 4217")

    def add(self, other: "Money") -> "Money":
        if self.currency != other.currency:
            raise DomainError("Cannot add different currencies")
        return Money(self.amount + other.amount, self.currency)

    @classmethod
    def zero(cls, currency: str) -> "Money":
        return cls(Decimal("0"), currency)


@dataclass(frozen=True)
class Email:
    value: str

    def __post_init__(self):
        if "@" not in self.value or "." not in self.value.split("@")[1]:
            raise ValueError(f"Invalid email: {self.value}")
```

### TypeScript

```typescript
class Money {
  private constructor(
    readonly amount: number,
    readonly currency: string
  ) {
    if (amount < 0) throw new DomainError("Money cannot be negative");
  }

  static create(amount: number, currency: string): Money {
    return new Money(amount, currency);
  }

  add(other: Money): Money {
    if (this.currency !== other.currency)
      throw new DomainError("Cannot add different currencies");
    return new Money(this.amount + other.amount, this.currency);
  }

  equals(other: Money): boolean {
    return this.amount === other.amount && this.currency === other.currency;
  }
}
```

### Do / Don't

```python
# DO: Value object with validation
total = Money(Decimal("29.99"), "USD")
tax = Money(Decimal("2.40"), "USD")
final = total.add(tax)  # returns new Money

# DON'T: Primitive obsession
total = 29.99          # what currency? can it be negative?
tax = 2.40
final = total + tax    # no domain rules enforced
```

---

## Domain Events

Something that happened in the domain that other parts of the system care about. Always named in **past tense**.

### Naming Convention
`[Noun][PastTenseVerb]`: `OrderPlaced`, `PaymentReceived`, `InventoryReserved`, `PatientDischarged`

### Structure

```python
@dataclass(frozen=True)
class OrderPlaced:
    order_id: str
    customer_id: str
    total: Decimal
    occurred_at: datetime

    # Events are facts — immutable, timestamped, self-describing
```

### Publishing Pattern

```python
class Order:
    def __init__(self, order_id: OrderId):
        self.id = order_id
        self._events: list = []

    def place(self) -> None:
        if self._status == OrderStatus.PLACED:
            raise DomainError("Order already placed")
        self._status = OrderStatus.PLACED
        self._events.append(OrderPlaced(
            order_id=str(self.id),
            customer_id=str(self.customer_id),
            total=self.total.amount,
            occurred_at=datetime.utcnow(),
        ))

    def collect_events(self) -> list:
        events = self._events.copy()
        self._events.clear()
        return events
```

Application service dispatches after persistence:

```python
class PlaceOrderHandler:
    def __init__(self, repo: OrderRepository, event_bus: EventBus):
        self._repo = repo
        self._bus = event_bus

    def handle(self, cmd: PlaceOrderCommand) -> None:
        order = self._repo.get(cmd.order_id)
        order.place()
        self._repo.save(order)
        for event in order.collect_events():
            self._bus.publish(event)
```

---

## Repositories

A repository provides a **collection-like interface** for accessing aggregates. The interface lives in the domain; the implementation lives in infrastructure.

### Pattern

```python
# Domain layer — interface only
from abc import ABC, abstractmethod

class OrderRepository(ABC):
    @abstractmethod
    def get(self, order_id: OrderId) -> Order:
        """Raises NotFound if missing."""

    @abstractmethod
    def save(self, order: Order) -> None: ...

    @abstractmethod
    def find_by_customer(self, customer_id: CustomerId) -> list[Order]: ...
```

```python
# Infrastructure layer — implementation
class SqlOrderRepository(OrderRepository):
    def __init__(self, session: Session):
        self._session = session

    def get(self, order_id: OrderId) -> Order:
        row = self._session.query(OrderModel).get(str(order_id))
        if not row:
            raise OrderNotFound(order_id)
        return self._to_domain(row)

    def save(self, order: Order) -> None:
        model = self._to_model(order)
        self._session.merge(model)
        self._session.flush()  # flush, NOT commit — UoW commits
```

### Do / Don't

```python
# DO: Collection-like interface, no persistence leaking
orders = repo.find_by_customer(customer_id)
repo.save(order)

# DON'T: Leaking persistence concerns
repo.session.query(Order).filter_by(customer_id=cid).all()  # exposes ORM
repo.save(order)
repo.commit()  # repository should not control transactions
```

---

## Domain Services

For logic that **doesn't naturally belong to a single entity**. Domain services are stateless and named after the operation they perform.

### When to Use
- Logic requires multiple aggregates
- Logic doesn't fit any single entity
- Calculations that are domain concepts themselves

```python
class TransferService:
    """Transferring money involves two accounts — belongs to neither."""

    def transfer(
        self,
        source: Account,
        target: Account,
        amount: Money,
    ) -> TransferResult:
        if source.balance < amount:
            raise InsufficientFunds(source.id, amount)
        source.debit(amount)
        target.credit(amount)
        return TransferResult(source.id, target.id, amount)
```

### Do / Don't
- **DO**: Stateless, uses domain objects, named after the domain operation
- **DON'T**: Hold state, call infrastructure directly, become a god service

---

## Specifications

Encapsulate business rules as composable, reusable objects. Useful when the same rule appears in multiple places or rules are combined with AND/OR logic.

```python
@dataclass
class Specification(ABC):
    @abstractmethod
    def is_satisfied_by(self, candidate) -> bool: ...

    def and_(self, other: "Specification") -> "Specification":
        return AndSpecification(self, other)

    def or_(self, other: "Specification") -> "Specification":
        return OrSpecification(self, other)

# Usage
class OrderIsOverdue(Specification):
    def is_satisfied_by(self, order: Order) -> bool:
        return order.due_date < datetime.utcnow() and not order.is_paid

class OrderIsHighValue(Specification):
    def is_satisfied_by(self, order: Order) -> bool:
        return order.total > Money(Decimal("1000"), "USD")

# Compose
needs_attention = OrderIsOverdue().and_(OrderIsHighValue())
urgent_orders = [o for o in orders if needs_attention.is_satisfied_by(o)]
```

---

## Summary Table

| Pattern | Lives In | Key Trait | Example |
|---------|----------|-----------|---------|
| Aggregate | Domain | Consistency boundary | `Order` with `OrderLine`s |
| Entity | Domain | Identity-based equality | `Patient`, `Account` |
| Value Object | Domain | Immutable, structural eq | `Money`, `Email`, `Address` |
| Domain Event | Domain | Past-tense fact | `OrderPlaced` |
| Repository | Interface: Domain, Impl: Infra | Collection-like access | `OrderRepository` |
| Domain Service | Domain | Stateless cross-aggregate logic | `TransferService` |
| Specification | Domain | Composable business rule | `OrderIsOverdue` |
