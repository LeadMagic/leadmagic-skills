---
name: error-handling
description: Error handling patterns for React 19, Next.js 16, and APIs. Use when implementing error boundaries, API error responses, logging, or user-friendly error messages. Triggers on "error handling", "error boundary", "try catch", "error message", "exception".
license: MIT
metadata:
  author: leadmagic
  version: "2.0.0"
---

# Error Handling

Comprehensive error handling patterns for React, Next.js, and APIs.

## Quick Reference

| Pattern | Use Case | Location |
|---------|----------|----------|
| `error.tsx` | Page-level errors | `app/[route]/error.tsx` |
| `global-error.tsx` | Root layout errors | `app/global-error.tsx` |
| `not-found.tsx` | 404 pages | `app/not-found.tsx` |
| Custom error classes | API errors | `lib/errors.ts` |
| Server Action result | Form errors | Return `{ success, error }` |

---

## Next.js Error Boundaries

See `rules/nextjs-boundaries.md` for detailed patterns.

### Quick Setup

```typescript
// app/dashboard/error.tsx
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong</h2>
      <p>{error.message}</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

### Error Hierarchy

```
app/
├── global-error.tsx   # Root layout errors
├── error.tsx          # App-level errors
├── not-found.tsx      # 404 page
└── dashboard/
    └── error.tsx      # Dashboard errors (catches first)
```

---

## API Error Handling

See `rules/api-errors.md` for detailed patterns.

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
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND')
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public errors: Record<string, string[]>) {
    super(message, 400, 'VALIDATION_ERROR')
  }
}
```

### Response Format

```json
{
  "error": {
    "message": "User-friendly message",
    "code": "ERROR_CODE",
    "details": {}
  }
}
```

---

## Server Action Errors

See `rules/server-actions.md` for detailed patterns.

### Result Pattern

```typescript
'use server'

type ActionResult =
  | { success: true; data: { id: string } }
  | { success: false; error: string; fieldErrors?: Record<string, string[]> }

export async function createPost(
  prevState: ActionResult | null,
  formData: FormData
): Promise<ActionResult> {
  try {
    // Validate and process
    return { success: true, data: { id: '123' } }
  } catch (e) {
    return { success: false, error: 'Something went wrong' }
  }
}
```

---

## React Error Boundary (Client)

```typescript
'use client'

import { Component, ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
}

export class ErrorBoundary extends Component<Props, State> {
  state = { hasError: false }

  static getDerivedStateFromError(): State {
    return { hasError: true }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <div>Something went wrong</div>
    }
    return this.props.children
  }
}
```

---

## Logging

```typescript
// lib/logger.ts
type LogLevel = 'debug' | 'info' | 'warn' | 'error'

export const logger = {
  error: (message: string, context?: Record<string, unknown>) => {
    console.error(JSON.stringify({
      level: 'error',
      message,
      timestamp: new Date().toISOString(),
      ...context,
    }))
  },
  // ... other levels
}

// Usage
logger.error('Payment failed', { userId, error: err.message })
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Exposing stack traces | Return user-friendly messages |
| Missing `prevState` in actions | Add as first parameter |
| Not logging errors | Always log before returning |
| Generic error messages | Include context (error ID, action) |
| Throwing from Server Actions | Return result objects instead |
| No recovery option | Provide reset/retry buttons |

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
- Log sensitive data (passwords, tokens)
