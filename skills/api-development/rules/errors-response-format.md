---
title: Structured Error Responses
impact: HIGH
impactDescription: Better developer experience and debugging
tags: errors, responses, developer-experience
---

## Structured Error Responses

Return consistent, informative error responses that help developers understand and fix issues quickly.

**Incorrect (inconsistent, unhelpful errors):**

```typescript
// Generic message, no structure
return new Response('Something went wrong', { status: 500 })

// Inconsistent formats
return Response.json({ error: 'Not found' })
return Response.json({ message: 'Invalid input', status: 400 })
return Response.json({ err: { msg: 'Unauthorized' } })

// Exposing internal details
return Response.json({
  error: 'Database error: connection refused to postgres://user:pass@...'
})

// No way to trace the request
return Response.json({ error: 'Rate limit exceeded' }, { status: 429 })
```

**Correct (structured, consistent errors):**

```typescript
// Standard error response interface
interface ErrorResponse {
  error: {
    code: string           // Machine-readable error code
    message: string        // Human-readable message
    details?: ErrorDetail[] // Optional field-level details
    requestId: string      // For tracing/support
    docs?: string          // Link to documentation
  }
}

interface ErrorDetail {
  field?: string
  code?: string
  message: string
}

// Error response factory
function errorResponse(
  status: number,
  code: string,
  message: string,
  options: {
    details?: ErrorDetail[]
    requestId?: string
    docs?: string
  } = {}
): Response {
  const { details, requestId, docs } = options

  return new Response(JSON.stringify({
    error: {
      code,
      message,
      ...(details && { details }),
      requestId: requestId || crypto.randomUUID(),
      ...(docs && { docs }),
    },
  }), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...(requestId && { 'X-Request-ID': requestId }),
    },
  })
}
```

**Standard Error Codes:**

```typescript
// Define consistent error codes
const ERROR_CODES = {
  // Authentication (401)
  UNAUTHORIZED: 'Authentication required',
  INVALID_API_KEY: 'API key is invalid or expired',
  TOKEN_EXPIRED: 'Authentication token has expired',

  // Authorization (403)
  FORBIDDEN: 'You do not have permission for this action',
  INSUFFICIENT_SCOPE: 'API key lacks required scope',

  // Validation (400)
  VALIDATION_ERROR: 'Request validation failed',
  INVALID_PARAMETER: 'Invalid parameter value',
  MISSING_PARAMETER: 'Required parameter is missing',

  // Not Found (404)
  NOT_FOUND: 'Resource not found',
  ENDPOINT_NOT_FOUND: 'API endpoint does not exist',

  // Conflict (409)
  CONFLICT: 'Resource already exists',
  VERSION_CONFLICT: 'Resource was modified by another request',

  // Rate Limiting (429)
  RATE_LIMIT_EXCEEDED: 'Too many requests',

  // Server (500)
  INTERNAL_ERROR: 'An unexpected error occurred',
  SERVICE_UNAVAILABLE: 'Service temporarily unavailable',
} as const

type ErrorCode = keyof typeof ERROR_CODES
```

**Validation Errors with Details:**

```typescript
import { z } from 'zod'

function handleValidationError(error: z.ZodError, requestId: string): Response {
  return errorResponse(400, 'VALIDATION_ERROR', 'Request validation failed', {
    requestId,
    details: error.issues.map(issue => ({
      field: issue.path.join('.'),
      code: issue.code,
      message: issue.message,
    })),
    docs: 'https://api.example.com/docs/errors#validation',
  })
}

// Example output:
// {
//   "error": {
//     "code": "VALIDATION_ERROR",
//     "message": "Request validation failed",
//     "details": [
//       { "field": "email", "code": "invalid_string", "message": "Invalid email format" },
//       { "field": "age", "code": "too_small", "message": "Must be at least 18" }
//     ],
//     "requestId": "req_abc123",
//     "docs": "https://api.example.com/docs/errors#validation"
//   }
// }
```

**Error Handling Middleware:**

```typescript
// Global error handler
export async function errorHandler(
  request: Request,
  ctx: Context,
  handler: () => Promise<Response>
): Promise<Response> {
  try {
    return await handler()
  } catch (error) {
    const requestId = ctx.custom.requestId

    // Known application errors
    if (error instanceof AppError) {
      return errorResponse(
        error.statusCode,
        error.code,
        error.message,
        { requestId, details: error.details }
      )
    }

    // Zod validation errors
    if (error instanceof z.ZodError) {
      return handleValidationError(error, requestId)
    }

    // Log unknown errors (but don't expose to client)
    console.error({
      level: 'error',
      message: 'Unhandled error',
      error: error.message,
      stack: error.stack,
      requestId,
    })

    // Generic error response
    return errorResponse(500, 'INTERNAL_ERROR',
      'An unexpected error occurred. Please try again or contact support.',
      { requestId }
    )
  }
}
```

**Error Response Examples:**

```json
// 400 Bad Request - Validation
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "message": "Must be a valid email address" }
    ],
    "requestId": "req_abc123"
  }
}

// 401 Unauthorized
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Missing or invalid Authorization header",
    "requestId": "req_abc123",
    "docs": "https://api.example.com/docs/authentication"
  }
}

// 429 Rate Limited
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please slow down.",
    "requestId": "req_abc123"
  }
}

// 500 Internal Error
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred. Please try again.",
    "requestId": "req_abc123"
  }
}
```
