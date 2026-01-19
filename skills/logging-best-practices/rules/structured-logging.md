---
title: Structured Logging Patterns
impact: CRITICAL
impactDescription: Enable querying instead of grep-ing
tags: logging, structured, json, observability
---

## Structured Logging Patterns

Structured logging means emitting logs as **key-value pairs** (usually JSON) instead of plain strings.

### Why Structured?

```typescript
// ❌ WRONG: Plain string
console.log(`Payment failed for user ${userId}: ${error.message}`)
// Output: "Payment failed for user 123: Card declined"
// Problem: Can't query by user_id or error type

// ✅ CORRECT: Structured
logger.error({
  event: 'payment_failed',
  user_id: userId,
  error_type: error.name,
  error_code: error.code,
  error_message: error.message,
})
// Output: {"event":"payment_failed","user_id":"123","error_type":"PaymentError",...}
// Benefit: Query by any field
```

---

## Logger Setup

### Pino (Node.js - Recommended)

```typescript
import pino from 'pino'

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: () => `,"timestamp":"${new Date().toISOString()}"`,
  base: {
    service: process.env.SERVICE_NAME,
    version: process.env.VERSION,
    region: process.env.REGION,
  },
})

// Usage
logger.info({ user_id: '123', action: 'login' }, 'User logged in')
```

### Winston (Node.js)

```typescript
import winston from 'winston'

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  defaultMeta: {
    service: process.env.SERVICE_NAME,
    version: process.env.VERSION,
  },
  transports: [new winston.transports.Console()],
})
```

### Console (Browser/Edge)

```typescript
// Simple structured logger for edge/browser
const logger = {
  _base: {
    service: 'frontend',
    version: '1.0.0',
  },

  _log(level: string, data: object, message?: string) {
    const entry = {
      ...this._base,
      level,
      timestamp: new Date().toISOString(),
      ...data,
      ...(message && { message }),
    }
    console[level === 'error' ? 'error' : 'log'](JSON.stringify(entry))
  },

  info(data: object, message?: string) {
    this._log('info', data, message)
  },

  error(data: object, message?: string) {
    this._log('error', data, message)
  },

  warn(data: object, message?: string) {
    this._log('warn', data, message)
  },
}
```

---

## Log Levels

| Level | When to Use |
|-------|-------------|
| `error` | Unexpected failures, exceptions, 5xx |
| `warn` | Recoverable issues, deprecations, approaching limits |
| `info` | Business events, request completion |
| `debug` | Detailed troubleshooting (disable in prod) |
| `trace` | Very verbose (never in prod) |

### Level Guidelines

```typescript
// ERROR: Something broke unexpectedly
logger.error({
  error_type: 'DatabaseError',
  error_message: 'Connection refused',
  query: 'SELECT * FROM users',
})

// WARN: Something concerning but handled
logger.warn({
  event: 'rate_limit_approaching',
  user_id: '123',
  current: 900,
  limit: 1000,
})

// INFO: Normal business events (wide events)
logger.info({
  request_id: 'req_abc',
  status_code: 200,
  duration_ms: 150,
})

// DEBUG: Disable in production
logger.debug({
  cache_key: 'user:123',
  cache_hit: false,
})
```

---

## Common Patterns

### Request Logging Middleware

```typescript
function requestLogger(logger: Logger) {
  return async (ctx, next) => {
    const start = Date.now()
    const requestId = crypto.randomUUID()

    // Child logger with request context
    ctx.logger = logger.child({ request_id: requestId })

    try {
      await next()
    } finally {
      ctx.logger.info({
        method: ctx.req.method,
        path: ctx.req.path,
        status_code: ctx.res.status,
        duration_ms: Date.now() - start,
      })
    }
  }
}
```

### Error Logging

```typescript
function logError(logger: Logger, error: Error, context?: object) {
  logger.error({
    error_type: error.name,
    error_message: error.message,
    error_code: (error as any).code,
    error_stack: error.stack,
    retriable: (error as any).retriable ?? false,
    ...context,
  })
}

// Usage
try {
  await processPayment(order)
} catch (error) {
  logError(logger, error, {
    order_id: order.id,
    user_id: order.userId,
    amount_cents: order.total,
  })
  throw error
}
```

### Child Loggers (Scoped Context)

```typescript
// Base logger
const logger = pino({ base: { service: 'api' } })

// Request-scoped
const requestLogger = logger.child({
  request_id: 'req_123',
  user_id: 'user_456',
})

// All logs include parent context
requestLogger.info({ action: 'checkout' })
// Output: {"service":"api","request_id":"req_123","user_id":"user_456","action":"checkout"}
```

---

## Anti-Patterns

```typescript
// ❌ String interpolation
logger.info(`User ${userId} purchased ${itemCount} items for $${total}`)

// ✅ Structured fields
logger.info({
  event: 'purchase_completed',
  user_id: userId,
  item_count: itemCount,
  total_cents: totalCents,
})

// ❌ Logging objects with toString
logger.info('User: ' + user)

// ✅ Spread relevant fields
logger.info({
  event: 'user_loaded',
  user_id: user.id,
  user_subscription: user.plan,
})

// ❌ Inconsistent field names
logger.info({ userId: '123' })
logger.info({ user_id: '123' })
logger.info({ uid: '123' })

// ✅ Consistent naming (snake_case recommended)
logger.info({ user_id: '123' })
```

---

## Field Naming Conventions

Use **snake_case** consistently:

| Good | Bad |
|------|-----|
| `user_id` | `userId`, `UserId` |
| `request_id` | `requestId`, `reqId` |
| `duration_ms` | `durationMs`, `duration` |
| `error_type` | `errorType`, `type` |
| `created_at` | `createdAt`, `timestamp` |

---

## Output Formats

### Development (Pretty)

```typescript
const logger = pino({
  transport: {
    target: 'pino-pretty',
    options: { colorize: true },
  },
})
```

### Production (JSON Lines)

```
{"level":"info","timestamp":"2025-01-15T10:00:00Z","request_id":"req_123","status_code":200}
{"level":"error","timestamp":"2025-01-15T10:00:01Z","request_id":"req_124","error_type":"ValidationError"}
```

One JSON object per line, easy to parse and ingest.
