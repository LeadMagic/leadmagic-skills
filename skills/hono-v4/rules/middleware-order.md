---
title: Order Middleware Correctly
impact: HIGH
impactDescription: Correct order prevents security issues and improves performance
tags: middleware, security, logging, auth
---

## Order Middleware Correctly

Middleware executes in the order registered. Follow this order: logging → CORS → security → auth → validation → business logic.

**Incorrect (wrong order causes issues):**

```typescript
import { Hono } from 'hono'
import { jwt } from 'hono/jwt'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'

const app = new Hono()

// ❌ Auth before CORS - preflight requests fail
app.use('*', jwt({ secret: env.JWT_SECRET }))
app.use('*', cors())

// ❌ Logger after auth - failed auth requests not logged
app.use('*', logger())
```

**Correct (proper middleware order):**

```typescript
import { Hono } from 'hono'
import { jwt } from 'hono/jwt'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { secureHeaders } from 'hono/secure-headers'
import { timing } from 'hono/timing'

const app = new Hono<{ Bindings: Bindings }>()

// 1. Timing (measure everything)
app.use('*', timing())

// 2. Logging (log all requests including failures)
app.use('*', logger())

// 3. CORS (handle preflight before any auth)
app.use('*', cors({
  origin: ['https://app.example.com'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}))

// 4. Security headers
app.use('*', secureHeaders())

// 5. Health check (before auth so monitoring works)
app.get('/health', (c) => c.json({ status: 'ok' }))

// 6. Auth (protect routes that need it)
app.use('/api/*', jwt({ secret: env.JWT_SECRET }))

// 7. Rate limiting (after auth to rate limit per user)
app.use('/api/*', rateLimiter())

// 8. Routes
app.route('/api/users', usersRouter)
app.route('/api/posts', postsRouter)
```

**Order explanation:**
1. **Timing** - Start measuring as early as possible
2. **Logging** - Log everything, including failed requests
3. **CORS** - Handle preflight OPTIONS before auth rejects them
4. **Security headers** - Apply to all responses
5. **Health checks** - Allow monitoring without auth
6. **Authentication** - Verify identity on protected routes
7. **Rate limiting** - Limit by authenticated user
8. **Business logic** - Your actual handlers
