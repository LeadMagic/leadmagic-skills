---
name: logging-best-practices
description: Production logging patterns with wide events, structured logging, and observability. Use when implementing logging, debugging production issues, or building observability. Triggers on "logging", "logs", "observability", "debugging", "tracing", "wide events".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Logging Best Practices

Modern logging patterns for production systems. Based on wide events and structured logging principles.

## The Problem with Traditional Logging

Traditional logging is optimized for **writing**, not **querying**. When something breaks:

- You grep through millions of lines
- Context is scattered across services
- User IDs are logged 47 different ways
- The one log you need is missing

**The fix**: Wide events (canonical log lines) with structured, high-cardinality data.

---

## Core Concepts

| Term | Definition |
|------|------------|
| **Structured Logging** | JSON key-value pairs, not strings |
| **Wide Event** | One comprehensive log per request per service |
| **Canonical Log Line** | The authoritative record of what happened |
| **Cardinality** | Unique values a field can have (user_id = high) |
| **Dimensionality** | Number of fields in your event (more = better) |
| **Tail Sampling** | Keep errors/slow requests, sample the rest |

---

## Wide Events

See `rules/wide-events.md` for detailed patterns.

### Instead of This (17 log lines):

```
INFO: Request received
DEBUG: Validating JWT
DEBUG: JWT valid for user-123
INFO: Loading user profile
DEBUG: Cache miss for user-123
INFO: Querying database
WARN: Slow query detected (847ms)
INFO: User loaded successfully
...
```

### Do This (1 wide event):

```json
{
  "timestamp": "2025-01-15T10:23:45.612Z",
  "request_id": "req_8bf7ec2d",
  "trace_id": "abc123",
  "service": "api-gateway",
  "version": "2.4.1",

  "method": "POST",
  "path": "/api/checkout",
  "status_code": 500,
  "duration_ms": 1247,

  "user": {
    "id": "user_456",
    "subscription": "premium",
    "account_age_days": 847
  },

  "error": {
    "type": "PaymentError",
    "code": "card_declined",
    "message": "Card declined by issuer",
    "retriable": false
  },

  "db": { "queries": 3, "duration_ms": 892 },
  "cache": { "hit": false, "key": "user:456" }
}
```

One event. Everything you need.

---

## Implementation Pattern

```typescript
// middleware/wideEvent.ts
export function wideEventMiddleware() {
  return async (ctx, next) => {
    const startTime = Date.now()

    // Initialize wide event
    const event: Record<string, unknown> = {
      request_id: ctx.get('requestId'),
      timestamp: new Date().toISOString(),
      method: ctx.req.method,
      path: ctx.req.path,
      service: process.env.SERVICE_NAME,
      version: process.env.SERVICE_VERSION,
    }

    // Make accessible to handlers
    ctx.set('wideEvent', event)

    try {
      await next()
      event.status_code = ctx.res.status
      event.outcome = 'success'
    } catch (error) {
      event.status_code = 500
      event.outcome = 'error'
      event.error = {
        type: error.name,
        message: error.message,
        code: error.code,
        retriable: error.retriable ?? false,
      }
      throw error
    } finally {
      event.duration_ms = Date.now() - startTime
      logger.info(event)  // Emit once at the end
    }
  }
}
```

### Enrich in Handlers

```typescript
app.post('/checkout', async (ctx) => {
  const event = ctx.get('wideEvent')
  const user = ctx.get('user')

  // Add user context
  event.user = {
    id: user.id,
    subscription: user.subscription,
    account_age_days: daysSince(user.createdAt),
  }

  // Add business context
  const cart = await getCart(user.id)
  event.cart = {
    id: cart.id,
    item_count: cart.items.length,
    total_cents: cart.total,
  }

  // Process and track
  const paymentStart = Date.now()
  const result = await processPayment(cart)

  event.payment = {
    provider: result.provider,
    latency_ms: Date.now() - paymentStart,
    attempt: result.attemptNumber,
  }

  return ctx.json({ orderId: result.orderId })
})
```

---

## What to Include

See `rules/what-to-log.md` for complete checklist.

### Always Include

| Category | Fields |
|----------|--------|
| **Identity** | `request_id`, `trace_id`, `span_id` |
| **Timing** | `timestamp`, `duration_ms` |
| **Service** | `service`, `version`, `region`, `deployment_id` |
| **Request** | `method`, `path`, `status_code` |
| **User** | `user_id`, `subscription`, `account_age` |
| **Error** | `type`, `code`, `message`, `retriable`, `stack` |

### Business Context (varies by endpoint)

- Cart contents, order value
- Feature flags enabled
- A/B test variants
- Payment method, provider
- External service latencies

---

## Tail Sampling

See `rules/sampling.md` for strategies.

Keep costs manageable while never losing important events:

```typescript
function shouldSample(event: WideEvent): boolean {
  // Always keep errors
  if (event.status_code >= 500) return true
  if (event.error) return true

  // Always keep slow requests (above p99)
  if (event.duration_ms > 2000) return true

  // Always keep VIP users
  if (event.user?.subscription === 'enterprise') return true

  // Always keep flagged requests (debugging rollouts)
  if (event.feature_flags?.new_checkout_flow) return true

  // Random sample the rest at 5%
  return Math.random() < 0.05
}
```

### Sampling Rules

| Condition | Sample Rate |
|-----------|-------------|
| Errors (5xx) | 100% |
| Slow requests (>p99) | 100% |
| VIP/Enterprise users | 100% |
| Feature flag rollouts | 100% |
| Everything else | 1-5% |

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `console.log("Payment failed")` | Structured: `{ event: "payment_failed", code: "..." }` |
| Logging inside loops | Log once with aggregated data |
| Missing request_id | Add correlation ID middleware |
| Sensitive data in logs | Redact PII, mask tokens |
| Only logging errors | Log success with context too |
| String concatenation | Use structured fields |
| No sampling at scale | Implement tail sampling |
| Debug logs in production | Use log levels properly |

---

## Queries You Can Run

With wide events, you query structured data:

```sql
-- Find checkout failures for premium users
SELECT * FROM logs
WHERE path = '/checkout'
  AND status_code = 500
  AND user.subscription = 'premium'
  AND timestamp > now() - INTERVAL 1 HOUR

-- P99 latency by endpoint
SELECT path, percentile(duration_ms, 0.99) as p99
FROM logs
WHERE timestamp > now() - INTERVAL 1 DAY
GROUP BY path

-- Errors correlated with feature flag
SELECT error.code, count(*) as count
FROM logs
WHERE feature_flags.new_checkout = true
  AND error IS NOT NULL
GROUP BY error.code
ORDER BY count DESC
```

---

## Quick Reference

| Pattern | When |
|---------|------|
| Wide events | Every request, every service |
| Tail sampling | High-traffic production |
| Correlation IDs | Distributed systems |
| Structured JSON | Always (never plain strings) |
| Business context | Checkout, payments, critical paths |
| Error enrichment | All catch blocks |

Reference: [loggingsucks.com](https://loggingsucks.com/)
