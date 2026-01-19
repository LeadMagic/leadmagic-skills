---
title: What to Log - Field Checklist
impact: HIGH
impactDescription: Complete context for debugging production issues
tags: logging, fields, context, observability
---

## What to Log - Field Checklist

### Identity (Always Required)

```typescript
{
  request_id: string      // Unique per request, for correlation
  trace_id: string        // Distributed tracing ID
  span_id: string         // Current service span
  timestamp: string       // ISO 8601 format
}
```

### Service Context (Always Required)

```typescript
{
  service: {
    name: string          // "checkout-service"
    version: string       // "2.4.1"
    deployment_id: string // "deploy_abc123"
    region: string        // "us-east-1"
    environment: string   // "production"
  }
}
```

### Request Details (Always Required)

```typescript
{
  request: {
    method: string        // "POST"
    path: string          // "/api/checkout"
    query: object         // URL params (sanitized)
    ip: string            // Client IP
    user_agent: string    // Browser/client info
  }
}
```

### Response Details (Always Required)

```typescript
{
  response: {
    status_code: number   // 200, 500, etc.
    bytes: number         // Response size
    content_type: string  // "application/json"
  }
}
```

### Timing (Always Required)

```typescript
{
  timing: {
    duration_ms: number   // Total request time
    db_ms: number         // Database time
    cache_ms: number      // Cache lookup time
    external_ms: number   // External API calls
  }
}
```

---

### User Context (When Authenticated)

```typescript
{
  user: {
    id: string            // User identifier
    subscription: string  // "free", "premium", "enterprise"
    account_age_days: number
    lifetime_value_cents: number
    is_internal: boolean  // Internal/test account
    // NEVER log: email, name, password, tokens
  }
}
```

### Business Context (Endpoint-Specific)

```typescript
// Checkout endpoint
{
  cart: {
    id: string
    item_count: number
    total_cents: number
    coupon_code: string
  },
  payment: {
    method: string        // "card", "paypal"
    provider: string      // "stripe", "braintree"
    attempt: number       // Retry count
  }
}

// Search endpoint
{
  search: {
    query: string
    filters: object
    results_count: number
    page: number
  }
}

// Upload endpoint
{
  upload: {
    file_type: string
    size_bytes: number
    bucket: string
  }
}
```

---

### Error Context (On Failure)

```typescript
{
  error: {
    type: string          // "ValidationError", "PaymentError"
    code: string          // "card_declined", "invalid_input"
    message: string       // Human-readable
    retriable: boolean    // Can the client retry?
    provider_code: string // External service error code
    field: string         // Which field failed (validation)
    stack: string         // Stack trace (internal only)
  }
}
```

### Dependency Tracking

```typescript
{
  dependencies: {
    database: {
      queries: number
      duration_ms: number
      slow_query: boolean
    },
    cache: {
      hits: number
      misses: number
      duration_ms: number
    },
    stripe: {
      calls: number
      duration_ms: number
      status: "success" | "error"
    }
  }
}
```

### Feature Flags & Experiments

```typescript
{
  feature_flags: {
    new_checkout_flow: boolean
    dark_mode: boolean
    fraud_check_v2: boolean
  },
  experiment: {
    id: string            // "checkout_redesign"
    variant: string       // "control", "treatment_a"
  }
}
```

---

## Sensitive Data Rules

### Never Log

- Passwords, secrets, API keys
- Full credit card numbers
- Social security numbers
- Full email addresses (use domain only)
- Session tokens, JWTs
- Personal health information

### Mask or Redact

```typescript
// Credit card
card: "****4242"

// Email (log domain only)
email_domain: "company.com"

// API keys
api_key: "sk_***abc"

// IP addresses (consider hashing)
ip_hash: sha256(ip + salt)
```

### Sanitization Helper

```typescript
function sanitizeForLogging(data: unknown): unknown {
  const sensitive = ['password', 'token', 'secret', 'apiKey', 'authorization']

  if (typeof data !== 'object' || data === null) return data

  return Object.fromEntries(
    Object.entries(data).map(([key, value]) => {
      if (sensitive.some(s => key.toLowerCase().includes(s))) {
        return [key, '[REDACTED]']
      }
      if (typeof value === 'object') {
        return [key, sanitizeForLogging(value)]
      }
      return [key, value]
    })
  )
}
```

---

## Cardinality Guide

| Field | Cardinality | Index? |
|-------|-------------|--------|
| `request_id` | Very High | Yes |
| `user_id` | High | Yes |
| `path` | Medium | Yes |
| `status_code` | Low | Yes |
| `method` | Very Low | Yes |
| `error.message` | High | No (use code) |
| `user_agent` | Very High | No (parse first) |

High-cardinality fields are what make logs useful for debugging specific issues.
