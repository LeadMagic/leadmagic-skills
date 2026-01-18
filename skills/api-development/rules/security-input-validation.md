---
title: Input Validation and Sanitization
impact: HIGH
impactDescription: Prevents injection attacks and data corruption
tags: security, validation, sanitization, input
---

## Input Validation and Sanitization

Validate and sanitize all input at the edge before processing. Never trust client data.

**Incorrect (no validation or incomplete):**

```typescript
// No validation at all
export async function createUser(request: Request) {
  const body = await request.json()
  return db.users.create(body) // Whatever the client sends!
}

// Partial validation, missing edge cases
export async function updateUser(request: Request) {
  const { id } = params
  const { email } = await request.json()

  if (!email) {
    return errorResponse(400, 'MISSING_EMAIL', 'Email required')
  }

  // No format validation, length check, or sanitization
  return db.users.update({ where: { id }, data: { email } })
}

// SQL injection vulnerability
const { search } = await request.json()
const results = await db.$queryRaw`SELECT * FROM users WHERE name LIKE '%${search}%'`
```

**Correct (comprehensive validation):**

```typescript
import { z } from 'zod'

// Define strict schemas
const createUserSchema = z.object({
  email: z.string()
    .email('Invalid email format')
    .max(255, 'Email too long')
    .toLowerCase()
    .trim(),

  name: z.string()
    .min(1, 'Name required')
    .max(100, 'Name too long')
    .trim()
    .regex(/^[\p{L}\p{N}\s\-']+$/u, 'Name contains invalid characters'),

  password: z.string()
    .min(12, 'Password must be at least 12 characters')
    .max(128, 'Password too long')
    .regex(/[A-Z]/, 'Password must contain uppercase letter')
    .regex(/[a-z]/, 'Password must contain lowercase letter')
    .regex(/[0-9]/, 'Password must contain number'),

  role: z.enum(['user', 'admin', 'viewer']).default('user'),

  metadata: z.record(z.string().max(1000))
    .optional()
    .refine(
      (obj) => !obj || Object.keys(obj).length <= 10,
      'Too many metadata fields'
    ),
})

// Validate all requests
export async function createUser(request: Request, ctx: Context) {
  // Parse JSON safely
  let body: unknown
  try {
    body = await request.json()
  } catch {
    return errorResponse(400, 'INVALID_JSON', 'Request body must be valid JSON')
  }

  // Validate against schema
  const result = createUserSchema.safeParse(body)

  if (!result.success) {
    return errorResponse(400, 'VALIDATION_ERROR', 'Invalid request data', {
      requestId: ctx.custom.requestId,
      details: result.error.issues.map(issue => ({
        field: issue.path.join('.'),
        message: issue.message,
      })),
    })
  }

  // Use validated data
  const user = await db.users.create({ data: result.data })
  return Response.json({ data: user }, { status: 201 })
}
```

**URL Parameter Validation:**

```typescript
const idSchema = z.string()
  .uuid('Invalid ID format')
  .or(z.string().regex(/^[a-z0-9]{20,30}$/, 'Invalid ID format'))

const paginationSchema = z.object({
  limit: z.coerce.number().int().min(1).max(100).default(20),
  offset: z.coerce.number().int().min(0).default(0),
  sort: z.enum(['created_at', '-created_at', 'name', '-name']).optional(),
})

export async function listUsers(request: Request, ctx: Context) {
  const url = new URL(request.url)

  const pagination = paginationSchema.safeParse({
    limit: url.searchParams.get('limit'),
    offset: url.searchParams.get('offset'),
    sort: url.searchParams.get('sort'),
  })

  if (!pagination.success) {
    return errorResponse(400, 'INVALID_PARAMETERS', 'Invalid query parameters', {
      requestId: ctx.custom.requestId,
      details: pagination.error.issues.map(i => ({
        field: i.path.join('.'),
        message: i.message,
      })),
    })
  }

  const { limit, offset, sort } = pagination.data
  // Use validated params...
}
```

**Content Type Validation:**

```typescript
// Validate content type before parsing
export async function validateContentType(request: Request): Promise<Response | null> {
  const contentType = request.headers.get('Content-Type')

  if (request.method !== 'GET' && request.method !== 'DELETE') {
    if (!contentType?.includes('application/json')) {
      return errorResponse(415, 'UNSUPPORTED_MEDIA_TYPE',
        'Content-Type must be application/json')
    }
  }

  return null
}

// Limit request body size
export async function validateBodySize(request: Request): Promise<Response | null> {
  const contentLength = parseInt(request.headers.get('Content-Length') || '0')
  const maxSize = 1024 * 1024 // 1MB

  if (contentLength > maxSize) {
    return errorResponse(413, 'PAYLOAD_TOO_LARGE',
      `Request body must be less than ${maxSize / 1024}KB`)
  }

  return null
}
```

**Sanitize for Output:**

```typescript
// HTML escape for any user content that might be rendered
function escapeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')
}

// Sanitize URLs
const urlSchema = z.string()
  .url()
  .refine(url => {
    const parsed = new URL(url)
    return ['http:', 'https:'].includes(parsed.protocol)
  }, 'Only HTTP(S) URLs allowed')
  .refine(url => {
    const parsed = new URL(url)
    return !['localhost', '127.0.0.1', '0.0.0.0'].includes(parsed.hostname)
  }, 'Local URLs not allowed')
```

**Safe Database Queries:**

```typescript
// Always use parameterized queries
const search = sanitizedInput.search

// ✓ Correct: Parameterized
const results = await db.users.findMany({
  where: { name: { contains: search } }
})

// ✓ Correct: Tagged template with escaping
const results = await db.$queryRaw`
  SELECT * FROM users WHERE name ILIKE ${`%${search}%`}
`

// ✗ Wrong: String concatenation
const results = await db.$queryRawUnsafe(
  `SELECT * FROM users WHERE name LIKE '%${search}%'`
)
```
