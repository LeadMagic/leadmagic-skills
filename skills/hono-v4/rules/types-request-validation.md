---
title: Validate Requests with Zod Schemas
impact: CRITICAL
impactDescription: Type-safe request validation with automatic error responses
tags: validation, zod, types, middleware
---

## Validate Requests with Zod Schemas

Use `@hono/zod-validator` to validate request bodies, query parameters, and path parameters with automatic type inference.

**Incorrect (manual validation, no type safety):**

```typescript
app.post('/users', async (c) => {
  const body = await c.req.json()

  // Manual validation - error prone, no types
  if (!body.email || typeof body.email !== 'string') {
    return c.json({ error: 'Invalid email' }, 400)
  }
  if (!body.name || typeof body.name !== 'string') {
    return c.json({ error: 'Invalid name' }, 400)
  }

  // body is still 'any'
  const user = await createUser(body)
  return c.json(user)
})
```

**Correct (Zod validation with type inference):**

```typescript
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

// Define schema once, get validation + types
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150).optional(),
})

// Reusable type
type CreateUserInput = z.infer<typeof createUserSchema>

app.post('/users',
  zValidator('json', createUserSchema),
  async (c) => {
    // Fully typed: { email: string, name: string, age?: number }
    const data = c.req.valid('json')

    const user = await createUser(c.env.DB, data)
    return c.json(user, 201)
  }
)

// Validate query params
const listUsersSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().optional(),
})

app.get('/users',
  zValidator('query', listUsersSchema),
  async (c) => {
    const { page, limit, search } = c.req.valid('query')
    // page: number, limit: number, search: string | undefined
    return c.json(await listUsers(c.env.DB, { page, limit, search }))
  }
)

// Validate path params
const userIdSchema = z.object({
  id: z.string().uuid(),
})

app.get('/users/:id',
  zValidator('param', userIdSchema),
  async (c) => {
    const { id } = c.req.valid('param')
    // id is validated as UUID string
    return c.json(await getUser(c.env.DB, id))
  }
)
```

Zod validation provides:
- Automatic 400 responses with error details
- Full TypeScript type inference
- Runtime validation matching compile-time types
