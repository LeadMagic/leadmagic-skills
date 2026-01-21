---
name: hono-v4
description: Best practices and patterns for building high-performance APIs using Hono v4.11+ on Cloudflare Workers. Use when creating new Workers, adding routes, writing middleware, handling requests, or optimizing edge performance. Triggers on "build API", "create endpoint", "Hono middleware", "route handler".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "2.2.0"
  context7: honojs/hono
---

# Hono v4 Best Practices

Comprehensive guide for building production-ready APIs with Hono v4.11+ on Cloudflare Workers.

## What's New in Hono v4.11

| Feature | Description |
|---------|-------------|
| `tryGetContext()` | Returns `undefined` instead of throwing when context unavailable |
| Typed URL for `hc` | Pass base URL as type parameter for precise URL types |
| Custom `NotFoundResponse` | Module augmentation for typed `c.notFound()` |
| Async CSRF handlers | `IsAllowedOriginHandler` can be async |
| CSP report-to/report-uri | Secure headers directive support |

## SECURITY ALERT: JWT Algorithm Confusion (v4.11.4)

**Affected versions:** < 4.11.4 | **Severity:** HIGH
**Fix:** Upgrade and explicitly specify `alg` in JWT middleware

```typescript
// PATCHED - alg is now REQUIRED
app.use('/auth/*', jwt({
  secret: 'it-is-very-secret',
  alg: 'HS256', // REQUIRED - prevents algorithm confusion
}))
```

---

## When to Apply

Reference these guidelines when:
- Creating new Hono v4 applications on Cloudflare Workers
- Implementing route handlers and middleware
- Handling request/response patterns
- Optimizing for edge performance
- Writing type-safe APIs with TypeScript

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Type Safety | CRITICAL | `types-` |
| 2 | Middleware | HIGH | `middleware-` |
| 3 | Error Handling | HIGH | `errors-` |

## Quick Reference

### 1. Type Safety (CRITICAL)

- `types-env-bindings` - Define typed environment bindings for D1, KV, R2
- `types-request-validation` - Validate requests with Zod schemas

### 2. Middleware Patterns (HIGH)

- `middleware-order` - Order middleware correctly (logging → auth → validation)

### 3. Error Handling (HIGH)

- `errors-global-handler` - Implement global error handler with onError

## How to Use

Read individual rule files for detailed explanations:

```
rules/types-env-bindings.md
rules/types-request-validation.md
rules/middleware-order.md
rules/errors-global-handler.md
```

Each rule file contains:
- Brief explanation of why it matters
- Incorrect code example
- Correct code example

## Project Structure

Recommended Hono v4 project structure:

```
src/
├── index.ts           # App entry, exports default
├── routes/
│   ├── index.ts       # Route aggregation
│   ├── users.ts       # User routes
│   └── health.ts      # Health check
├── middleware/
│   ├── auth.ts        # Authentication
│   ├── logging.ts     # Request logging
│   └── validation.ts  # Request validation
├── lib/
│   ├── db.ts          # Database helpers
│   └── cache.ts       # Caching utilities
├── types/
│   └── bindings.ts    # Environment type definitions
└── utils/
    └── errors.ts      # Error utilities
```

## Essential Patterns

### Basic App Setup

```typescript
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'

type Bindings = {
  DB: D1Database
  CACHE: KVNamespace
  API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

// Middleware
app.use('*', logger())
app.use('*', cors())

// Routes
app.get('/health', (c) => c.json({ status: 'ok' }))

// Error handling
app.onError((err, c) => {
  console.error(err)
  return c.json({ error: 'Internal Server Error' }, 500)
})

app.notFound((c) => c.json({ error: 'Not Found' }, 404))

export default app
```

### Route with Validation

```typescript
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1)
})

app.post('/users',
  zValidator('json', createUserSchema),
  async (c) => {
    const data = c.req.valid('json')
    // data is typed: { email: string, name: string }
    const user = await createUser(c.env.DB, data)
    return c.json(user, 201)
  }
)
```

---

## Common Mistakes

### 1. Not Accessing c.error in Middleware

Errors thrown in handlers are available via `c.error` in middleware.

```typescript
// ❌ WRONG - can't see what error occurred
app.use(async (c, next) => {
  await next()
  // No access to error
})

// ✅ CORRECT - check c.error after next()
app.use(async (c, next) => {
  await next()
  if (c.error) {
    console.error('Error occurred:', c.error)
    // Log to error tracking service
  }
})
```

### 2. Forgetting onError and notFound Handlers

```typescript
// ❌ WRONG - unhandled errors return ugly response
const app = new Hono()
app.get('/users', async (c) => {
  throw new Error('DB connection failed') // Returns 500 with no body
})

// ✅ CORRECT - add global handlers
const app = new Hono()

app.onError((err, c) => {
  console.error('Error:', err)
  return c.json({ error: 'Internal server error' }, 500)
})

app.notFound((c) => {
  return c.json({ error: 'Not found' }, 404)
})
```

### 3. Not Using HTTPException

```typescript
// ❌ WRONG - manual error responses scattered everywhere
app.get('/users/:id', async (c) => {
  const user = await getUser(c.req.param('id'))
  if (!user) {
    return c.json({ error: 'User not found' }, 404)
  }
  return c.json(user)
})

// ✅ CORRECT - throw HTTPException
import { HTTPException } from 'hono/http-exception'

app.get('/users/:id', async (c) => {
  const user = await getUser(c.req.param('id'))
  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }
  return c.json(user)
})
```

### 4. Wrong Middleware Order

```typescript
// ❌ WRONG - auth runs before logging, can't log auth failures
app.use('*', authMiddleware)
app.use('*', logger())

// ✅ CORRECT - logging first, then auth
app.use('*', logger())
app.use('*', cors())
app.use('/api/*', authMiddleware)
```

### 5. Not Typing Context Variables

```typescript
// ❌ WRONG - no type safety for context variables
app.use(async (c, next) => {
  c.set('user', await getUser(c))
  await next()
})

app.get('/profile', (c) => {
  const user = c.get('user') // Type: unknown
})

// ✅ CORRECT - type the variables
type Variables = {
  user: { id: string; name: string }
}

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

app.use(async (c, next) => {
  c.set('user', await getUser(c))
  await next()
})

app.get('/profile', (c) => {
  const user = c.get('user') // Type: { id: string; name: string }
})
```

### 6. Parsing Body Multiple Times

```typescript
// ❌ WRONG - body can only be read once
app.post('/users', async (c) => {
  const body1 = await c.req.json()
  const body2 = await c.req.json() // Error! Body already consumed
})

// ✅ CORRECT - parse once, reuse
app.post('/users', async (c) => {
  const body = await c.req.json()
  // Use body multiple times
  validate(body)
  process(body)
})
```

### 7. Blocking Operations Without waitUntil

```typescript
// ❌ WRONG - analytics blocks response
app.post('/users', async (c) => {
  const user = await createUser(c.env.DB, data)
  await trackEvent('user_created', user.id) // Blocks response!
  return c.json(user, 201)
})

// ✅ CORRECT - use waitUntil for non-blocking
app.post('/users', async (c) => {
  const user = await createUser(c.env.DB, data)
  c.executionCtx.waitUntil(trackEvent('user_created', user.id))
  return c.json(user, 201)
})
```

