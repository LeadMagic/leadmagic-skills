---
title: Wide Events / Canonical Log Lines
impact: CRITICAL
impactDescription: Transform debugging from archaeology to analytics
tags: logging, wide-events, canonical-log-line, observability
---

## Wide Events / Canonical Log Lines

A wide event is **one comprehensive log event per request per service** containing all context needed for debugging.

### The Mental Model Shift

> Instead of logging *what your code is doing*, log *what happened to this request*.

Stop thinking about logs as a debugging diary. Start thinking about them as structured records of business events.

---

## Complete Wide Event Structure

```json
{
  "timestamp": "2025-01-15T10:23:45.612Z",
  "request_id": "req_8bf7ec2d",
  "trace_id": "trace_abc123",
  "span_id": "span_def456",

  "service": {
    "name": "checkout-service",
    "version": "2.4.1",
    "deployment_id": "deploy_789",
    "region": "us-east-1",
    "environment": "production"
  },

  "request": {
    "method": "POST",
    "path": "/api/checkout",
    "query": {},
    "headers": {
      "user_agent": "Mozilla/5.0...",
      "content_type": "application/json"
    },
    "ip": "192.168.1.42",
    "geo": {
      "country": "US",
      "city": "San Francisco"
    }
  },

  "response": {
    "status_code": 500,
    "bytes": 1247,
    "content_type": "application/json"
  },

  "timing": {
    "duration_ms": 1247,
    "db_ms": 892,
    "cache_ms": 12,
    "external_ms": 343
  },

  "user": {
    "id": "user_456",
    "email_domain": "company.com",
    "subscription": "premium",
    "account_age_days": 847,
    "lifetime_value_cents": 284700,
    "is_internal": false
  },

  "business": {
    "cart_id": "cart_xyz",
    "cart_items": 3,
    "cart_total_cents": 15999,
    "coupon_code": "SAVE20",
    "payment_method": "card",
    "payment_provider": "stripe"
  },

  "error": {
    "type": "PaymentError",
    "code": "card_declined",
    "message": "Card declined by issuer",
    "retriable": false,
    "provider_code": "insufficient_funds",
    "stack": "PaymentError: Card declined\n    at processPayment..."
  },

  "dependencies": {
    "database": { "queries": 3, "duration_ms": 892 },
    "cache": { "hits": 2, "misses": 1, "duration_ms": 12 },
    "stripe": { "calls": 1, "duration_ms": 343, "status": "error" }
  },

  "feature_flags": {
    "new_checkout_flow": true,
    "express_payment": false,
    "fraud_check_v2": true
  },

  "experiment": {
    "id": "checkout_redesign",
    "variant": "treatment_b"
  },

  "outcome": "error"
}
```

---

## Building Wide Events

### Middleware Pattern

```typescript
// Initialize at request start
function createWideEvent(req: Request): WideEvent {
  return {
    timestamp: new Date().toISOString(),
    request_id: req.headers.get('x-request-id') || crypto.randomUUID(),
    trace_id: req.headers.get('x-trace-id'),

    service: {
      name: process.env.SERVICE_NAME,
      version: process.env.VERSION,
      region: process.env.REGION,
    },

    request: {
      method: req.method,
      path: new URL(req.url).pathname,
      ip: req.headers.get('x-forwarded-for'),
    },

    timing: { start: Date.now() },
    dependencies: {},
  }
}

// Emit at request end
function finalizeWideEvent(event: WideEvent, response: Response) {
  event.response = {
    status_code: response.status,
    bytes: response.headers.get('content-length'),
  }
  event.timing.duration_ms = Date.now() - event.timing.start
  event.outcome = response.ok ? 'success' : 'error'

  delete event.timing.start  // Internal field
  logger.info(event)
}
```

### Enrichment Helpers

```typescript
// Add user context
function enrichUser(event: WideEvent, user: User) {
  event.user = {
    id: user.id,
    subscription: user.plan,
    account_age_days: daysSince(user.createdAt),
    lifetime_value_cents: user.ltv,
    is_internal: user.email.endsWith('@company.com'),
  }
}

// Track dependency calls
function trackDependency(
  event: WideEvent,
  name: string,
  fn: () => Promise<T>
): Promise<T> {
  const start = Date.now()
  try {
    const result = await fn()
    event.dependencies[name] = {
      duration_ms: Date.now() - start,
      status: 'success',
    }
    return result
  } catch (error) {
    event.dependencies[name] = {
      duration_ms: Date.now() - start,
      status: 'error',
      error: error.message,
    }
    throw error
  }
}
```

---

## Key Principles

1. **One event per request per service** - Not 17 log lines
2. **Build throughout the request** - Don't log incrementally
3. **Emit at the end** - After you know the outcome
4. **Include business context** - Not just technical data
5. **High cardinality is good** - user_id, request_id, cart_id
6. **High dimensionality is good** - 50+ fields is normal

---

## Anti-Patterns

```typescript
// ❌ WRONG: Scattered logs
logger.info('Request received')
logger.debug('Validating JWT')
logger.info('User loaded', { userId })
logger.warn('Slow query', { duration: 847 })
logger.info('Request completed')

// ✅ CORRECT: Single wide event
logger.info({
  request_id: 'req_123',
  user: { id: userId },
  timing: { duration_ms: 1247, db_ms: 847 },
  outcome: 'success'
})
```

Reference: [loggingsucks.com](https://loggingsucks.com/)
