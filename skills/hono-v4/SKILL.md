---
name: hono-v4
description: Best practices and patterns for building high-performance APIs using Hono v4 on Cloudflare Workers. Use when creating new Workers, adding routes, writing middleware, handling requests, or optimizing edge performance. Triggers on "build API", "create endpoint", "Hono middleware", "route handler".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Hono v4 Best Practices

Comprehensive guide for building production-ready APIs with Hono v4 on Cloudflare Workers. Contains 30+ rules across 6 categories, prioritized by impact.

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
| 1 | Type Safety & Bindings | CRITICAL | `types-` |
| 2 | Routing & Handlers | HIGH | `routing-` |
| 3 | Middleware Patterns | HIGH | `middleware-` |
| 4 | Error Handling | MEDIUM-HIGH | `errors-` |
| 5 | Performance | MEDIUM | `perf-` |
| 6 | Testing | MEDIUM | `testing-` |

## Quick Reference

### 1. Type Safety & Bindings (CRITICAL)

- `types-env-bindings` - Define typed environment bindings
- `types-context-generics` - Use Hono generics for type-safe context
- `types-request-validation` - Validate requests with Zod schemas
- `types-response-types` - Type API responses explicitly

### 2. Routing & Handlers (HIGH)

- `routing-explicit-methods` - Use explicit HTTP method handlers
- `routing-path-params` - Extract typed path parameters
- `routing-query-params` - Parse and validate query strings
- `routing-route-groups` - Organize routes with basePath
- `routing-chained-handlers` - Chain multiple handlers properly

### 3. Middleware Patterns (HIGH)

- `middleware-order` - Order middleware correctly (logging → auth → validation)
- `middleware-async` - Handle async middleware properly
- `middleware-context-passing` - Pass data through context variables
- `middleware-early-return` - Return early to skip downstream handlers
- `middleware-factory` - Create reusable middleware factories

### 4. Error Handling (MEDIUM-HIGH)

- `errors-global-handler` - Implement global error handler with onError
- `errors-http-exceptions` - Use HTTPException for HTTP errors
- `errors-validation` - Handle validation errors consistently
- `errors-not-found` - Custom 404 handler with notFound
- `errors-structured-responses` - Return structured error responses

### 5. Performance (MEDIUM)

- `perf-streaming-responses` - Stream large responses
- `perf-json-shortcuts` - Use c.json() instead of new Response()
- `perf-header-helpers` - Use built-in header helpers
- `perf-body-parsing` - Parse body once, reuse result
- `perf-parallel-operations` - Parallelize independent operations

### 6. Testing (MEDIUM)

- `testing-app-request` - Use app.request() for testing
- `testing-mock-bindings` - Mock environment bindings properly
- `testing-middleware-isolation` - Test middleware in isolation

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/types-env-bindings.md
rules/routing-explicit-methods.md
rules/middleware-order.md
```

Each rule file contains:
- Brief explanation of why it matters
- Incorrect code example with explanation
- Correct code example with explanation
- Additional context and references

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

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
