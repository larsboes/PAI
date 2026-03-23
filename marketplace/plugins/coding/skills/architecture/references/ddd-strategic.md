# DDD Strategic Patterns

Practical reference for the *big-picture* patterns of Domain-Driven Design — how to carve a system into bounded contexts and how those contexts relate to each other.

---

## Decision Tree: Do I Need This Pattern?

```
Is the system a single team, single domain?
  YES -> Single bounded context, Clean Architecture is enough
  NO  -> Multiple teams or domains?
           YES -> Define bounded contexts (see below)
                  Do contexts share a model?
                    YES (small overlap) -> Shared Kernel
                    YES (large overlap) -> Rethink boundaries
                    NO -> Choose integration pattern per relationship

Do reads and writes have very different shapes/loads?
  YES -> Consider CQRS
  NO  -> Standard architecture is fine

Do you need full audit trail or temporal queries?
  YES -> Consider Event Sourcing
  NO  -> Standard persistence is fine
```

---

## Bounded Contexts

A bounded context is a **linguistic boundary** — inside it, every term has exactly one meaning. "Account" in Billing is not the same as "Account" in Identity.

### How to Identify Boundaries

1. **Language changes** — when the same word means different things to different people, you have a boundary
2. **Team boundaries** — different teams usually imply different contexts
3. **Rate of change** — parts that change together belong together
4. **Data ownership** — who is the source of truth for this data?

### Relationship to Microservices

A bounded context is a **logical** boundary. A microservice is a **deployment** boundary. They often align but don't have to — one context can be multiple services, or one service can host multiple small contexts (early stage).

```
Bounded Context != Microservice
Bounded Context  = Linguistic/model boundary
Microservice     = Deployment boundary
Often 1:1, but not required
```

---

## Context Maps

A context map describes how bounded contexts relate. Each relationship has a pattern:

| Pattern | Relationship | When to Use |
|---------|-------------|-------------|
| **Partnership** | Two teams cooperate closely | Both teams can change, mutual dependency acceptable |
| **Shared Kernel** | Small shared model | Teams agree on a tiny overlapping domain subset |
| **Customer-Supplier** | Upstream serves downstream | Upstream prioritizes downstream's needs |
| **Conformist** | Downstream accepts upstream's model | No leverage to influence upstream (e.g., external API) |
| **Anti-Corruption Layer** | Downstream translates upstream | Upstream model is messy or will change |
| **Open Host Service** | Upstream provides a clean API | Multiple consumers, upstream defines protocol |
| **Published Language** | Shared schema (e.g., protobuf, JSON Schema) | Formal contract between contexts |

### Visual

```
[Identity Context] --Partnership--> [Notification Context]
[Billing Context]  --Customer/Supplier--> [Order Context]
[Legacy CRM]       --ACL--> [Customer Context]
[Payment Gateway]  --Conformist--> [Billing Context]
```

---

## Anti-Corruption Layer (ACL)

Protects your domain from external or legacy models. Translates between "their" language and "yours."

### When to Use
- Integrating with a legacy system
- Consuming an external API whose model you don't control
- Upstream model is messy, inconsistent, or likely to change
- You want to avoid your domain leaking upstream concepts

### Implementation: Adapter + Translator

```python
# Your domain model
@dataclass(frozen=True)
class CustomerProfile:
    customer_id: CustomerId
    name: str
    email: Email
    tier: CustomerTier

# The legacy API returns this mess
# {"cust_no": "X-4421", "full_nm": "J. Smith", "email_addr": "j@x.com",
#  "level": 3, "active_flag": "Y"}

# ACL: Translator
class LegacyCrmTranslator:
    TIER_MAP = {1: CustomerTier.BRONZE, 2: CustomerTier.SILVER, 3: CustomerTier.GOLD}

    def to_customer_profile(self, raw: dict) -> CustomerProfile:
        return CustomerProfile(
            customer_id=CustomerId(raw["cust_no"]),
            name=raw["full_nm"],
            email=Email(raw["email_addr"]),
            tier=self.TIER_MAP.get(raw["level"], CustomerTier.BRONZE),
        )

# ACL: Adapter (implements your domain's port)
class LegacyCrmAdapter(CustomerLookup):
    def __init__(self, http_client: HttpClient, translator: LegacyCrmTranslator):
        self._http = http_client
        self._translator = translator

    def find_customer(self, customer_id: CustomerId) -> CustomerProfile:
        raw = self._http.get(f"/api/customers/{customer_id}")
        return self._translator.to_customer_profile(raw)
```

### TypeScript Example

```typescript
// ACL adapter implementing your domain's port
class LegacyCrmAdapter implements CustomerLookup {
  constructor(
    private http: HttpClient,
    private translator: LegacyCrmTranslator
  ) {}

  async findCustomer(id: CustomerId): Promise<CustomerProfile> {
    const raw = await this.http.get(`/api/customers/${id.value}`);
    return this.translator.toCustomerProfile(raw);
  }
}
```

### Do / Don't

```python
# DO: ACL translates at the boundary
profile = crm_adapter.find_customer(customer_id)  # returns YOUR domain type

# DON'T: Letting external models leak into your domain
legacy_data = crm_client.get_customer("X-4421")
order.customer_name = legacy_data["full_nm"]  # legacy field names in YOUR code
order.level = legacy_data["level"]            # their concepts in your domain
```

---

## Shared Kernel

A small, explicitly shared subset of the domain model. Both teams own it and must agree on changes.

### Rules
1. **Keep it minimal** — only what truly must be shared (IDs, core value objects)
2. **Version it** — treat it as a published package
3. **Both teams must agree on changes** — shared ownership means shared governance
4. **Test contract** — both sides have integration tests against the kernel

### When It's Appropriate
- Two closely related contexts that share a handful of value objects
- Example: `Money`, `Currency`, `UserId` shared between Billing and Orders

### When It's Not
- If the shared part keeps growing, your boundaries are wrong
- If teams can't coordinate changes, use ACL instead

---

## CQRS (Command Query Responsibility Segregation)

Separate the write model (commands) from the read model (queries). They can use different data stores, different schemas, different optimization strategies.

### When to Use
- Read and write loads are vastly different (read-heavy dashboards + occasional writes)
- Read model needs denormalized/materialized views
- Different authorization rules for reads vs writes
- Complex domain logic on write side, simple flat reads

### When NOT to Use
- Simple CRUD — CQRS adds accidental complexity
- Small team, single DB, reads and writes look similar

### Simple CQRS (Same DB, Different Models)

```python
# Command side: rich domain model
class PlaceOrderHandler:
    def __init__(self, repo: OrderRepository):
        self._repo = repo

    def handle(self, cmd: PlaceOrderCommand) -> OrderId:
        order = Order.create(cmd.customer_id, cmd.items)
        order.place()
        self._repo.save(order)
        return order.id

# Query side: optimized read model (no domain objects)
class OrderSummaryQuery:
    def __init__(self, db: ReadOnlyConnection):
        self._db = db

    def get_customer_orders(self, customer_id: str) -> list[OrderSummaryDTO]:
        rows = self._db.execute(
            "SELECT id, status, total, placed_at FROM orders WHERE customer_id = %s",
            [customer_id],
        )
        return [OrderSummaryDTO(**row) for row in rows]
```

### Full CQRS (Separate Stores)

```
Command -> Domain Model -> Event Store (write)
                              |
                         Domain Events
                              |
                         Projections -> Read DB (query-optimized)
                              |
Query <-------------------- Read Models
```

---

## Event Sourcing

Instead of storing current state, store the **sequence of events** that led to current state. State is derived by replaying events.

### When to Use
- Full audit trail is a requirement (finance, healthcare, compliance)
- Temporal queries: "What was the state on March 5th?"
- Event-driven architecture is already the primary pattern
- Complex domain where understanding "what happened" matters

### When NOT to Use (Seriously, Think Twice)
- Simple CRUD with no audit needs
- Team has no event sourcing experience (learning curve is steep)
- High-frequency updates with no replay needs
- Reporting on current state is the primary use case (use CQRS read models instead)

### Pattern

```python
# Events are the source of truth
events = [
    AccountOpened(account_id="A1", owner="Jane", opened_at=t0),
    MoneyDeposited(account_id="A1", amount=Decimal("500"), at=t1),
    MoneyWithdrawn(account_id="A1", amount=Decimal("100"), at=t2),
    MoneyDeposited(account_id="A1", amount=Decimal("200"), at=t3),
]

# State is derived by replaying
class Account:
    def __init__(self):
        self.balance = Decimal("0")
        self._changes: list = []

    def apply(self, event):
        match event:
            case MoneyDeposited(amount=amt):
                self.balance += amt
            case MoneyWithdrawn(amount=amt):
                self.balance -= amt

    @classmethod
    def from_events(cls, events: list) -> "Account":
        account = cls()
        for event in events:
            account.apply(event)
        return account
    # Current balance: 500 - 100 + 200 = 600
```

### Snapshots

For performance, periodically save a snapshot so you don't replay from the beginning:

```
Events: [1..1000] -> Snapshot at event 1000 -> Events: [1001..1005] -> Current state
```

---

## Hexagonal Architecture (Ports & Adapters)

The domain sits in the center. Everything else connects through **ports** (interfaces) and **adapters** (implementations).

### Structure

```
              Driving Side                    Driven Side
              (input)                         (output)
         +-----------------+            +------------------+
         |  REST Adapter   |            |  Postgres Adapter|
         |  CLI Adapter    |   PORTS    |  Redis Adapter   |
         |  Event Adapter  |---->|<-----|  Email Adapter   |
         +-----------------+    |      |  S3 Adapter      |
                                |      +------------------+
                          +-----+------+
                          |   DOMAIN   |
                          |  (pure)    |
                          +------------+
```

### Driving Ports (Input)
Define how the outside world can trigger your application:

```python
# Port (interface for the use case)
class PlaceOrderUseCase(ABC):
    @abstractmethod
    def execute(self, cmd: PlaceOrderCommand) -> OrderId: ...

# Driving adapter: REST
@app.post("/orders")
def place_order(body: OrderRequest):
    cmd = PlaceOrderCommand(**body.dict())
    return use_case.execute(cmd)  # use_case: PlaceOrderUseCase

# Driving adapter: CLI
@click.command()
def place_order_cli(customer_id: str, items: str):
    cmd = PlaceOrderCommand(customer_id, parse_items(items))
    use_case.execute(cmd)
```

### Driven Ports (Output)
Define what the domain needs from the outside world:

```python
# Port (interface the domain defines)
class OrderRepository(ABC):
    @abstractmethod
    def save(self, order: Order) -> None: ...

class NotificationSender(ABC):
    @abstractmethod
    def send(self, notification: Notification) -> None: ...

# Driven adapter: implements the port
class PostgresOrderRepository(OrderRepository):
    def save(self, order: Order) -> None:
        # SQL implementation

class EmailNotificationSender(NotificationSender):
    def send(self, notification: Notification) -> None:
        # SMTP implementation
```

### Key Insight
The domain defines the ports (interfaces). Adapters implement them. The domain never knows about adapters — dependency always points inward.

---

## Integration Patterns Between Bounded Contexts

How contexts talk to each other:

| Pattern | Coupling | Consistency | Use When |
|---------|----------|-------------|----------|
| **Shared Database** | Very high (anti-pattern) | Immediate | Never (in new systems) |
| **Synchronous REST/gRPC** | Medium | Request-time | Simple queries, low latency needed |
| **Async Messaging/Events** | Low | Eventual | Default choice for cross-context |
| **Event-Carried State Transfer** | Very low | Eventual | Consumer needs local copy of data |

### Do / Don't

```python
# DO: Async events between contexts
# Order Context publishes:
event_bus.publish(OrderPlaced(order_id="O1", customer_id="C1", total=99.99))

# Shipping Context subscribes:
@event_handler(OrderPlaced)
def on_order_placed(event: OrderPlaced):
    shipment = Shipment.create_for_order(event.order_id)
    shipment_repo.save(shipment)

# DON'T: Shared database between contexts
# Shipping context directly queries Order context's DB
shipping_service.query("SELECT * FROM orders.orders WHERE id = %s", [order_id])
# This couples Shipping to Order's internal schema — if Order refactors, Shipping breaks
```

---

## Summary: When to Use What

| You Have | Use |
|----------|-----|
| Multiple teams/domains | Bounded Contexts + Context Map |
| Messy external system | Anti-Corruption Layer |
| Two contexts share tiny model | Shared Kernel |
| Read/write asymmetry | CQRS |
| Audit trail / temporal queries | Event Sourcing |
| Need to swap infrastructure | Hexagonal / Ports & Adapters |
| Cross-context communication | Async Events (default) |
