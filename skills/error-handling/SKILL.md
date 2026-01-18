---
name: error-handling
description: Error handling patterns for React 19, Next.js 16, and APIs. Use when implementing error boundaries, API error responses, logging, or user-friendly error messages. Triggers on "error handling", "error boundary", "try catch", "error message", "exception", "logging".
license: MIT
metadata:
  author: leadmagic
  version: "2.0.0"
---

# Error Handling

Comprehensive error handling patterns for React, Next.js, and Cloudflare Workers.

---

## Next.js Error Boundaries

### Page-Level Error Boundary

```typescript
// app/dashboard/error.tsx
'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/button'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log to error reporting service
    console.error('Dashboard error:', error)
  }, [error])

  return (
    <div className="flex flex-col items-center justify-center min-h-[400px] gap-4">
      <div className="text-center">
        <h2 className="text-xl font-semibold">Something went wrong</h2>
        <p className="text-muted-foreground mt-2">
          {error.message || 'An unexpected error occurred'}
        </p>
        {error.digest && (
          <p className="text-xs text-muted-foreground mt-1">
            Error ID: {error.digest}
          </p>
        )}
      </div>
      <div className="flex gap-2">
        <Button onClick={() => reset()}>Try again</Button>
        <Button variant="outline" onClick={() => window.location.href = '/'}>
          Go home
        </Button>
      </div>
    </div>
  )
}
```

### Global Error Boundary

```typescript
// app/global-error.tsx
'use client'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <html>
      <body>
        <div className="flex flex-col items-center justify-center min-h-screen">
          <h1 className="text-2xl font-bold">Something went wrong!</h1>
          <button onClick={() => reset()}>Try again</button>
        </div>
      </body>
    </html>
  )
}
```

### Not Found Page

```typescript
// app/not-found.tsx
import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4">
      <h1 className="text-6xl font-bold">404</h1>
      <h2 className="text-xl text-muted-foreground">Page not found</h2>
      <p className="text-center max-w-md text-muted-foreground">
        The page you're looking for doesn't exist or has been moved.
      </p>
      <Button asChild>
        <Link href="/">Go home</Link>
      </Button>
    </div>
  )
}
```

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

### API Response Format

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

---

## Hono Error Handling

### Global Error Handler

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

  if (err instanceof ValidationError) {
    return c.json(
      { error: { message: err.message, code: 'VALIDATION_ERROR', details: err.errors } },
      400
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

### Throwing HTTP Exceptions

```typescript
import { HTTPException } from 'hono/http-exception'

app.get('/users/:id', async (c) => {
  const user = await getUser(c.req.param('id'))

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json(user)
})
```

---

## Server Action Error Handling

```typescript
// app/actions.ts
'use server'

import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  message: z.string().min(10),
})

type ActionResult =
  | { success: true; data: { id: string } }
  | { success: false; error: string; fieldErrors?: Record<string, string[]> }

export async function submitForm(formData: FormData): Promise<ActionResult> {
  try {
    const result = schema.safeParse({
      email: formData.get('email'),
      message: formData.get('message'),
    })

    if (!result.success) {
      return {
        success: false,
        error: 'Validation failed',
        fieldErrors: result.error.flatten().fieldErrors,
      }
    }

    const submission = await db.insert(submissions).values(result.data).returning()

    return { success: true, data: { id: submission[0].id } }
  } catch (e) {
    console.error('submitForm error:', e)
    return { success: false, error: 'Failed to submit form. Please try again.' }
  }
}
```

### Client Component Usage

```typescript
'use client'

import { useActionState } from 'react'
import { submitForm } from './actions'

export function ContactForm() {
  const [state, formAction, pending] = useActionState(submitForm, null)

  return (
    <form action={formAction}>
      <input name="email" type="email" required />
      {state?.fieldErrors?.email && (
        <p className="text-sm text-destructive">{state.fieldErrors.email[0]}</p>
      )}

      <textarea name="message" required />
      {state?.fieldErrors?.message && (
        <p className="text-sm text-destructive">{state.fieldErrors.message[0]}</p>
      )}

      {state?.error && !state.fieldErrors && (
        <p className="text-sm text-destructive">{state.error}</p>
      )}

      {state?.success && (
        <p className="text-sm text-green-600">Form submitted successfully!</p>
      )}

      <button type="submit" disabled={pending}>
        {pending ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  )
}
```

---

## React Error Boundaries (Client)

```typescript
// components/error-boundary.tsx
'use client'

import { Component, ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="p-4 border border-destructive rounded">
          <p className="text-destructive">Something went wrong</p>
        </div>
      )
    }

    return this.props.children
  }
}
```

---

## Logging

### Structured Logging

```typescript
// lib/logger.ts
type LogLevel = 'debug' | 'info' | 'warn' | 'error'

interface LogEntry {
  level: LogLevel
  message: string
  timestamp: string
  context?: Record<string, unknown>
}

function log(level: LogLevel, message: string, context?: Record<string, unknown>) {
  const entry: LogEntry = {
    level,
    message,
    timestamp: new Date().toISOString(),
    context,
  }

  // In production, send to logging service
  if (process.env.NODE_ENV === 'production') {
    // Send to Axiom, Logtail, etc.
    console.log(JSON.stringify(entry))
  } else {
    console[level](message, context)
  }
}

export const logger = {
  debug: (message: string, context?: Record<string, unknown>) => log('debug', message, context),
  info: (message: string, context?: Record<string, unknown>) => log('info', message, context),
  warn: (message: string, context?: Record<string, unknown>) => log('warn', message, context),
  error: (message: string, context?: Record<string, unknown>) => log('error', message, context),
}
```

### Usage

```typescript
import { logger } from '@/lib/logger'

try {
  const result = await processPayment(data)
  logger.info('Payment processed', { userId, amount: data.amount })
} catch (error) {
  logger.error('Payment failed', {
    userId,
    error: error instanceof Error ? error.message : 'Unknown error',
    stack: error instanceof Error ? error.stack : undefined,
  })
  throw error
}
```

---

## Best Practices

### Do

- Use custom error classes for different error types
- Return user-friendly error messages
- Log detailed errors server-side
- Include error IDs for support requests
- Provide recovery actions (retry, go back)
- Validate input before processing

### Don't

- Expose stack traces to users
- Return raw database errors
- Catch errors without handling them
- Use generic error messages everywhere
- Ignore async errors
- Log sensitive data (passwords, tokens)
