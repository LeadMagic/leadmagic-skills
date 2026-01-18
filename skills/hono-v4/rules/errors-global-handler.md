---
title: Implement Global Error Handler
impact: MEDIUM-HIGH
impactDescription: Consistent error responses and prevents information leakage
tags: errors, security, middleware
---

## Implement Global Error Handler

Use Hono's `onError` to catch all unhandled errors and return consistent, safe error responses.

**Incorrect (no global handler, exposes stack traces):**

```typescript
const app = new Hono()

app.get('/users/:id', async (c) => {
  // If this throws, the error bubbles up with full stack trace
  const user = await getUser(c.env.DB, c.req.param('id'))
  return c.json(user)
})

// Unhandled errors return 500 with stack trace in dev
// or generic error in prod - inconsistent
```

**Correct (global error handler with HTTPException support):**

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

const app = new Hono<{ Bindings: Bindings }>()

// Global error handler
app.onError((err, c) => {
  // Log full error for debugging (goes to wrangler tail)
  console.error({
    message: err.message,
    stack: err.stack,
    url: c.req.url,
    method: c.req.method,
  })

  // HTTPException - return the intended response
  if (err instanceof HTTPException) {
    return err.getResponse()
  }

  // Zod validation errors
  if (err.name === 'ZodError') {
    return c.json({
      error: 'Validation Error',
      details: JSON.parse(err.message),
    }, 400)
  }

  // D1 errors
  if (err.message?.includes('D1_ERROR')) {
    return c.json({
      error: 'Database Error',
      message: 'A database error occurred',
    }, 500)
  }

  // Generic error - never expose internal details
  return c.json({
    error: 'Internal Server Error',
    message: c.env.ENVIRONMENT === 'development'
      ? err.message
      : 'An unexpected error occurred',
  }, 500)
})

// 404 handler
app.notFound((c) => {
  return c.json({
    error: 'Not Found',
    message: `Route ${c.req.method} ${c.req.path} not found`,
  }, 404)
})

// Use HTTPException for expected errors
app.get('/users/:id', async (c) => {
  const user = await getUser(c.env.DB, c.req.param('id'))

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json(user)
})

// Custom HTTPException with JSON body
app.post('/login', async (c) => {
  const { email, password } = await c.req.json()
  const user = await authenticate(email, password)

  if (!user) {
    throw new HTTPException(401, {
      res: c.json({
        error: 'Unauthorized',
        message: 'Invalid email or password',
      }, 401),
    })
  }

  return c.json({ token: generateToken(user) })
})
```

This ensures:
- All errors are logged for debugging
- No stack traces leak to clients
- Consistent error response format
- Different handling for different error types
