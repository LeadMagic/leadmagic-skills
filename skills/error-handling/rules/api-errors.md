---
title: API Error Handling
impact: HIGH
impactDescription: Structured error responses for APIs
tags: api, errors, http, response-format
---

## API Error Handling

### Custom Error Classes

```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code?: string
  ) {
    super(message)
    this.name = 'AppError'
  }
}

export class ValidationError extends AppError {
  constructor(
    message: string,
    public errors: Record<string, string[]>
  ) {
    super(message, 400, 'VALIDATION_ERROR')
    this.name = 'ValidationError'
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND')
    this.name = 'NotFoundError'
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 401, 'UNAUTHORIZED')
    this.name = 'UnauthorizedError'
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Forbidden') {
    super(message, 403, 'FORBIDDEN')
    this.name = 'ForbiddenError'
  }
}

export class RateLimitError extends AppError {
  constructor(retryAfter?: number) {
    super('Too many requests', 429, 'RATE_LIMIT')
    this.name = 'RateLimitError'
  }
}
```

### API Response Helpers

```typescript
// lib/api-response.ts
import { NextResponse } from 'next/server'

interface ApiResponse<T> {
  data?: T
  error?: {
    message: string
    code?: string
    details?: unknown
  }
}

export function success<T>(data: T, status = 200) {
  return NextResponse.json<ApiResponse<T>>({ data }, { status })
}

export function error(
  message: string,
  status = 500,
  code?: string,
  details?: unknown
) {
  return NextResponse.json<ApiResponse<never>>(
    { error: { message, code, details } },
    { status }
  )
}
```

### Route Handler with Error Handling

```typescript
// app/api/posts/[id]/route.ts
import { NextRequest } from 'next/server'
import { success, error } from '@/lib/api-response'
import { NotFoundError, ValidationError } from '@/lib/errors'

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const post = await db.query.posts.findFirst({
      where: eq(posts.id, id),
    })

    if (!post) {
      throw new NotFoundError('Post')
    }

    return success(post)
  } catch (e) {
    if (e instanceof NotFoundError) {
      return error(e.message, e.statusCode, e.code)
    }

    console.error('GET /api/posts/[id] error:', e)
    return error('Internal server error', 500)
  }
}
```

### Hono Error Handler

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

const app = new Hono()

// Global error handler
app.onError((err, c) => {
  console.error('Error:', err)

  if (err instanceof HTTPException) {
    return c.json(
      { error: { message: err.message, code: 'HTTP_ERROR' } },
      err.status
    )
  }

  // Don't expose internal errors
  return c.json(
    { error: { message: 'Internal server error', code: 'INTERNAL_ERROR' } },
    500
  )
})

// 404 handler
app.notFound((c) => {
  return c.json(
    { error: { message: 'Not found', code: 'NOT_FOUND' } },
    404
  )
})
```

### Standard Error Response Format

```json
{
  "error": {
    "message": "Validation failed",
    "code": "VALIDATION_ERROR",
    "details": {
      "email": ["Invalid email format"],
      "password": ["Must be at least 8 characters"]
    }
  }
}
```
