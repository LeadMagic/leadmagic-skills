---
title: Use Edge Config for Feature Flags
impact: MEDIUM
impactDescription: Sub-millisecond reads at the edge without cold starts
tags: vercel, edge, feature-flags, configuration
---

## Use Edge Config for Feature Flags

Vercel Edge Config provides ultra-low latency (<15ms) global reads for configuration data. Use it for feature flags, redirects, and dynamic configuration instead of hitting databases or APIs from edge/middleware.

**Incorrect (database/API call in middleware):**

```typescript
// middleware.ts
import { NextResponse } from 'next/server'

export async function middleware(request: Request) {
  // ❌ Database call on every request - adds latency
  const flags = await fetch('https://api.example.com/flags').then(r => r.json())

  if (flags.maintenanceMode) {
    return NextResponse.redirect('/maintenance')
  }

  // ❌ External API for A/B test assignment
  const variant = await fetch('https://ab-service.com/assign').then(r => r.json())

  return NextResponse.next()
}
```

**Correct (Edge Config):**

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import { get } from '@vercel/edge-config'

export async function middleware(request: Request) {
  // ✅ Sub-millisecond read from Edge Config
  const maintenanceMode = await get('maintenanceMode')

  if (maintenanceMode) {
    return NextResponse.redirect(new URL('/maintenance', request.url))
  }

  // ✅ Feature flags at the edge
  const flags = await get<FeatureFlags>('featureFlags')

  if (flags?.newCheckout && request.nextUrl.pathname === '/checkout') {
    return NextResponse.rewrite(new URL('/checkout-v2', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
```

**Setup Edge Config:**

```bash
# Install
npm install @vercel/edge-config

# Link to your project (via Vercel CLI)
vercel env pull
```

```typescript
// Set EDGE_CONFIG environment variable in Vercel dashboard
// Or in .env.local for development:
EDGE_CONFIG=https://edge-config.vercel.com/ecfg_xxx?token=xxx
```

**Reading Values:**

```typescript
import { get, getAll, has } from '@vercel/edge-config'

// Get single value
const maintenance = await get<boolean>('maintenanceMode')

// Get multiple values
const { featureFlags, redirects } = await getAll(['featureFlags', 'redirects'])

// Check existence
const hasFlag = await has('experimentalFeature')

// With fallback
const limit = await get<number>('rateLimit') ?? 100
```

**Feature Flags Pattern:**

```typescript
// lib/flags.ts
import { get } from '@vercel/edge-config'

interface FeatureFlags {
  newDashboard: boolean
  aiAssistant: boolean
  darkMode: boolean
  experimentalApi: boolean
}

const defaultFlags: FeatureFlags = {
  newDashboard: false,
  aiAssistant: false,
  darkMode: true,
  experimentalApi: false,
}

export async function getFeatureFlags(): Promise<FeatureFlags> {
  try {
    const flags = await get<Partial<FeatureFlags>>('featureFlags')
    return { ...defaultFlags, ...flags }
  } catch {
    return defaultFlags
  }
}

// Usage in Server Component
export default async function Dashboard() {
  const flags = await getFeatureFlags()

  return (
    <div>
      {flags.newDashboard ? <NewDashboard /> : <LegacyDashboard />}
      {flags.aiAssistant && <AIAssistantWidget />}
    </div>
  )
}
```

**A/B Testing at Edge:**

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import { get } from '@vercel/edge-config'

export async function middleware(request: Request) {
  const experiments = await get<Experiment[]>('experiments')
  const response = NextResponse.next()

  for (const exp of experiments ?? []) {
    // Check if user already has assignment
    const existing = request.cookies.get(`exp_${exp.id}`)?.value

    if (existing) {
      response.headers.set(`x-experiment-${exp.id}`, existing)
      continue
    }

    // Assign variant based on percentage
    const variant = Math.random() < exp.percentage ? 'treatment' : 'control'

    response.cookies.set(`exp_${exp.id}`, variant, {
      httpOnly: true,
      maxAge: 60 * 60 * 24 * 30, // 30 days
    })
    response.headers.set(`x-experiment-${exp.id}`, variant)
  }

  return response
}
```

**When to Use Edge Config:**

| Use Case | Edge Config | Database |
|----------|-------------|----------|
| Feature flags | ✅ | ❌ (too slow) |
| A/B experiments | ✅ | ❌ |
| Redirects | ✅ | ❌ |
| Rate limit config | ✅ | ❌ |
| User data | ❌ | ✅ |
| Dynamic content | ❌ | ✅ |
| Large datasets | ❌ (8KB limit) | ✅ |

**Updating Edge Config:**

```typescript
// Via Vercel REST API (from Server Action or API route)
const response = await fetch(
  `https://api.vercel.com/v1/edge-config/${EDGE_CONFIG_ID}/items`,
  {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${VERCEL_API_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      items: [
        { operation: 'update', key: 'maintenanceMode', value: true },
      ],
    }),
  }
)
```

Changes propagate globally in ~300ms without redeployment.
