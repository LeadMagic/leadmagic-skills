---
name: sentry
description: Sentry error tracking and performance monitoring. Use when implementing error tracking, performance monitoring, or debugging production issues. Triggers on "Sentry", "error tracking", "monitoring", "crash reporting", "performance".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
  context7: getsentry/sentry-javascript
---

# Sentry - Error & Performance Monitoring

Real-time error tracking and performance monitoring for production applications.

## Installation

```bash
# Next.js (recommended)
npx @sentry/wizard@latest -i nextjs

# Manual installation
npm install @sentry/nextjs
```

## Environment Variables

```bash
SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
SENTRY_ORG=your-org
SENTRY_PROJECT=your-project
SENTRY_AUTH_TOKEN=sntrys_xxx  # For source maps
```

---

## Next.js Setup

### Instrumentation File

```typescript
// instrumentation.ts
export async function register() {
  if (process.env.NEXT_RUNTIME === 'nodejs') {
    await import('./sentry.server.config')
  }

  if (process.env.NEXT_RUNTIME === 'edge') {
    await import('./sentry.edge.config')
  }
}
```

### Server Config

```typescript
// sentry.server.config.ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.SENTRY_DSN,

  // Performance monitoring
  tracesSampleRate: 1.0, // 100% in dev, lower in prod

  // Profiling
  profilesSampleRate: 1.0,

  // Environment
  environment: process.env.NODE_ENV,

  // Release tracking
  release: process.env.VERCEL_GIT_COMMIT_SHA,
})
```

### Client Config

```typescript
// sentry.client.config.ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,

  tracesSampleRate: 1.0,

  // Replay for session recording
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,

  integrations: [
    Sentry.replayIntegration({
      maskAllText: true,
      blockAllMedia: true,
    }),
  ],
})
```

### next.config.js

```javascript
// next.config.js
import { withSentryConfig } from '@sentry/nextjs'

const nextConfig = {
  // Your config
}

export default withSentryConfig(nextConfig, {
  // Sentry webpack plugin options
  silent: true,
  org: process.env.SENTRY_ORG,
  project: process.env.SENTRY_PROJECT,

  // Upload source maps
  widenClientFileUpload: true,

  // Hide source maps from client
  hideSourceMaps: true,

  // Automatically tree-shake unused code
  disableLogger: true,
})
```

---

## Error Boundaries

### Global Error Boundary

```tsx
// app/global-error.tsx
'use client'

import * as Sentry from '@sentry/nextjs'
import { useEffect } from 'react'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    Sentry.captureException(error)
  }, [error])

  return (
    <html>
      <body>
        <h2>Something went wrong!</h2>
        <button onClick={() => reset()}>Try again</button>
      </body>
    </html>
  )
}
```

### Route Error Boundary

```tsx
// app/dashboard/error.tsx
'use client'

import * as Sentry from '@sentry/nextjs'
import { useEffect } from 'react'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    Sentry.captureException(error)
  }, [error])

  return (
    <div>
      <h2>Dashboard Error</h2>
      <p>{error.message}</p>
      <button onClick={() => reset()}>Retry</button>
    </div>
  )
}
```

---

## Manual Error Capturing

### Capture Exception

```typescript
import * as Sentry from '@sentry/nextjs'

try {
  await riskyOperation()
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      section: 'checkout',
    },
    extra: {
      orderId: order.id,
      userId: user.id,
    },
  })
}
```

### Capture Message

```typescript
Sentry.captureMessage('User exceeded rate limit', {
  level: 'warning',
  tags: { userId: user.id },
})
```

### Set User Context

```typescript
// After sign in
Sentry.setUser({
  id: user.id,
  email: user.email,
  username: user.name,
})

// After sign out
Sentry.setUser(null)
```

---

## Performance Monitoring

### Custom Transactions

```typescript
import * as Sentry from '@sentry/nextjs'

export async function processOrder(orderId: string) {
  return Sentry.startSpan(
    { name: 'processOrder', op: 'function' },
    async (span) => {
      // Child spans
      await Sentry.startSpan(
        { name: 'validateOrder', op: 'validation' },
        async () => {
          await validateOrder(orderId)
        }
      )

      await Sentry.startSpan(
        { name: 'chargePayment', op: 'payment' },
        async () => {
          await chargePayment(orderId)
        }
      )

      await Sentry.startSpan(
        { name: 'sendConfirmation', op: 'email' },
        async () => {
          await sendConfirmation(orderId)
        }
      )
    }
  )
}
```

### Custom Metrics

```typescript
import * as Sentry from '@sentry/nextjs'

// Counter
Sentry.metrics.increment('button_clicked', 1, {
  tags: { button: 'checkout' },
})

// Gauge
Sentry.metrics.gauge('queue_size', queueSize)

// Distribution (histogram)
Sentry.metrics.distribution('api_latency', responseTime, {
  tags: { endpoint: '/api/users' },
  unit: 'millisecond',
})

// Set (unique values)
Sentry.metrics.set('unique_users', userId)
```

---

## API Route Error Handling

```typescript
// app/api/users/route.ts
import * as Sentry from '@sentry/nextjs'

export async function GET() {
  try {
    const users = await db.user.findMany()
    return Response.json(users)
  } catch (error) {
    Sentry.captureException(error, {
      tags: { route: '/api/users' },
    })
    return Response.json({ error: 'Failed to fetch users' }, { status: 500 })
  }
}
```

### With Request Context

```typescript
export async function POST(request: Request) {
  return Sentry.withScope(async (scope) => {
    const body = await request.json()

    scope.setContext('request', {
      url: request.url,
      method: 'POST',
      body,
    })

    try {
      const user = await createUser(body)
      return Response.json(user, { status: 201 })
    } catch (error) {
      Sentry.captureException(error)
      return Response.json({ error: 'Failed to create user' }, { status: 500 })
    }
  })
}
```

---

## Server Actions

```typescript
'use server'

import * as Sentry from '@sentry/nextjs'

export async function createPost(formData: FormData) {
  return Sentry.withServerActionInstrumentation(
    'createPost',
    { recordResponse: true },
    async () => {
      const title = formData.get('title') as string

      try {
        const post = await db.post.create({ data: { title } })
        return { success: true, post }
      } catch (error) {
        Sentry.captureException(error)
        return { success: false, error: 'Failed to create post' }
      }
    }
  )
}
```

---

## Breadcrumbs

```typescript
// Add custom breadcrumb
Sentry.addBreadcrumb({
  category: 'navigation',
  message: 'User navigated to checkout',
  level: 'info',
})

// Add data breadcrumb
Sentry.addBreadcrumb({
  category: 'api',
  message: 'API call completed',
  data: {
    url: '/api/products',
    status: 200,
  },
  level: 'info',
})
```

---

## Filtering Events

```typescript
Sentry.init({
  dsn: process.env.SENTRY_DSN,

  beforeSend(event, hint) {
    // Filter out specific errors
    if (event.exception?.values?.[0]?.type === 'ChunkLoadError') {
      return null
    }

    // Remove sensitive data
    if (event.request?.data) {
      delete event.request.data.password
      delete event.request.data.creditCard
    }

    return event
  },

  ignoreErrors: [
    'ResizeObserver loop limit exceeded',
    'Non-Error promise rejection',
    /^Network request failed$/,
  ],
})
```

---

## Sampling

```typescript
Sentry.init({
  dsn: process.env.SENTRY_DSN,

  // Sample 10% of transactions in production
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,

  // Dynamic sampling
  tracesSampler: ({ name, parentSampled }) => {
    // Always sample checkout flow
    if (name.includes('checkout')) {
      return 1.0
    }

    // Lower rate for health checks
    if (name.includes('health')) {
      return 0.01
    }

    return 0.1
  },
})
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Missing DSN | Add `SENTRY_DSN` environment variable |
| No source maps | Configure `withSentryConfig` in next.config |
| Sampling too high | Use 0.1-0.2 for tracesSampleRate in prod |
| Not setting user | Call `Sentry.setUser()` after auth |
| Sensitive data leaking | Use `beforeSend` to scrub data |

---

## Quick Reference

| Function | Purpose |
|----------|---------|
| `Sentry.captureException(error)` | Report error |
| `Sentry.captureMessage(msg)` | Report message |
| `Sentry.setUser({ id, email })` | Set user context |
| `Sentry.setTag(key, value)` | Add tag |
| `Sentry.setContext(name, data)` | Add context |
| `Sentry.addBreadcrumb(...)` | Add breadcrumb |
| `Sentry.startSpan(...)` | Custom transaction |
| `Sentry.withScope(fn)` | Scoped context |

## References

- [Sentry Next.js Docs](https://docs.sentry.io/platforms/javascript/guides/nextjs/)
- [Performance Monitoring](https://docs.sentry.io/product/performance/)
- [Session Replay](https://docs.sentry.io/product/session-replay/)
