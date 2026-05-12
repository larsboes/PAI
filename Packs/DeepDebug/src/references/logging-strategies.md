# Logging Strategies for Debugging

How to add diagnostic logging that actually helps find bugs, not just fills up stdout.

---

## The Problem

Most debug logging is useless because it answers the wrong questions:
- `console.log("here")` — where is "here"? What state?
- `console.log(data)` — which data? From which call? At what point in the flow?
- `console.log("error:", e)` — what was the input? What was the state before the error?

## Effective Debug Logging

### Rule 1: Log at Boundaries

Every time data crosses a boundary (function call, API request, file read, DB query), log what goes in and what comes out.

```typescript
// BAD: logging in the middle of logic
function processOrder(order: Order) {
  console.log("processing...");
  // ... logic ...
  console.log("done");
}

// GOOD: logging at boundaries with context
async function processOrder(order: Order): Promise<Result> {
  console.error(`[processOrder] IN:`, {
    orderId: order.id,
    lineCount: order.lines.length,
    total: order.total,
  });

  const result = await doProcessing(order);

  console.error(`[processOrder] OUT:`, {
    orderId: order.id,
    status: result.status,
    duration: Date.now() - start,
  });

  return result;
}
```

### Rule 2: Log the Decision, Not the Data

```typescript
// BAD: dumping the whole object
console.log("config:", JSON.stringify(config, null, 2));

// GOOD: logging the decision that config drives
console.error(`[auth] Using ${config.authProvider} provider, ${config.mfaEnabled ? 'MFA on' : 'MFA off'}`);
```

### Rule 3: Use Structured Logging

```typescript
// BAD: string concatenation
console.log("User " + userId + " failed login attempt " + attemptNum);

// GOOD: structured data (can be parsed, filtered, aggregated)
console.error(JSON.stringify({
  event: "login_failed",
  userId,
  attempt: attemptNum,
  ip: req.ip,
  ts: Date.now(),
}));
```

### Rule 4: Log Before, Not After

```typescript
// BAD: only know about failure after it happened
try {
  await riskyOperation(input);
} catch (e) {
  console.error("failed:", e); // What was the input? What state?
}

// GOOD: log context before the risky operation
console.error(`[riskyOp] attempting with:`, { input, state: currentState });
try {
  await riskyOperation(input);
  console.error(`[riskyOp] success`);
} catch (e) {
  console.error(`[riskyOp] FAILED:`, { input, state: currentState, error: e.message });
  throw e;
}
```

---

## Temporary vs Permanent Logging

### Temporary (Debug Session)

Mark clearly so you can find and remove them:

```typescript
// DEBUG: remove after fixing #423
console.error(`🔴 DEBUG orderId=${order.id} state=${order.status} lines=${order.lines.length}`);
```

Find and remove after:
```bash
grep -rn "🔴 DEBUG" src/
```

### Permanent (Operational)

Use proper log levels with structured output:

```typescript
logger.info("order.placed", { orderId, customerId, total });
logger.warn("inventory.low", { productId, remaining: 3, threshold: 5 });
logger.error("payment.failed", { orderId, provider: "stripe", code: e.code });
```

---

## Multi-Component Systems

When debugging across multiple services/processes:

### Correlation IDs

Thread a unique ID through the entire request chain:

```typescript
// API gateway generates ID
const correlationId = crypto.randomUUID();
res.setHeader("X-Correlation-ID", correlationId);

// Every downstream service logs it
logger.info("processing", { correlationId, service: "orders", action: "create" });
// Forward to next service
fetch(url, { headers: { "X-Correlation-ID": correlationId } });
```

Then grep all logs for one correlation ID to see the full journey.

### Diff Logging

When comparing expected vs actual:

```typescript
console.error(`[validate] MISMATCH:`, {
  field: "total",
  expected: expectedTotal,
  actual: order.total,
  diff: order.total - expectedTotal,
  context: { orderId: order.id, lineCount: order.lines.length },
});
```

---

## Quick Reference

| Situation | What to Log | Where |
|-----------|------------|-------|
| API call | Method, URL, status code, duration | Before request + after response |
| DB query | Query (parameterized), duration, row count | Before + after |
| State transition | From state, to state, trigger | At transition point |
| Branch decision | Which branch taken and why | At the if/switch |
| Error | Input that caused it, state, stack | In catch block |
| Async handoff | What's being queued, by whom, correlation ID | At publish + consume |
