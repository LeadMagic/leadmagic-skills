---
name: env-variables
description: Environment variable patterns for Next.js and Cloudflare Workers. Use when configuring environment variables, validating env at runtime, or managing secrets across environments. Triggers on "env", "environment variables", ".env", "secrets", "configuration".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Environment Variables

Patterns for managing environment variables in Next.js and Cloudflare Workers.

---

## Next.js Environment Variables

### File Priority (highest to lowest)

```
.env.$(NODE_ENV).local   # .env.development.local, .env.production.local
.env.local               # Not loaded in test environment
.env.$(NODE_ENV)         # .env.development, .env.production
.env                     # Default
```

### Naming Convention

```env
# Server-only (not exposed to browser)
DATABASE_URL=postgresql://...
JWT_SECRET=your-secret-key
STRIPE_SECRET_KEY=sk_...

# Client-exposed (NEXT_PUBLIC_ prefix)
NEXT_PUBLIC_API_URL=https://api.example.com
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_...
```

### Type-Safe Environment with Zod

```typescript
// lib/env.ts
import { z } from 'zod'

const serverEnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  CLERK_SECRET_KEY: z.string().startsWith('sk_'),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  RESEND_API_KEY: z.string().startsWith('re_'),
})

const clientEnvSchema = z.object({
  NEXT_PUBLIC_APP_URL: z.string().url(),
  NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY: z.string().startsWith('pk_'),
  NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY: z.string().startsWith('pk_'),
})

// Validate server env (runs at build time)
const serverEnv = serverEnvSchema.parse(process.env)

// Validate client env
const clientEnv = clientEnvSchema.parse({
  NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
  NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY: process.env.NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY,
  NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY: process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY,
})

export const env = { ...serverEnv, ...clientEnv }
```

### Usage

```typescript
import { env } from '@/lib/env'

// Type-safe access
const dbUrl = env.DATABASE_URL // string
const isDev = env.NODE_ENV === 'development' // boolean expression
```

---

## Cloudflare Workers Environment

### wrangler.toml

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2025-01-01"
compatibility_flags = ["nodejs_compat"]

[vars]
ENVIRONMENT = "production"
API_VERSION = "v1"

# D1 Database
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "xxxx-xxxx-xxxx"

# KV Namespace
[[kv_namespaces]]
binding = "KV"
id = "xxxx-xxxx-xxxx"

# R2 Bucket
[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"

# Secrets (set via wrangler secret put)
# STRIPE_SECRET_KEY
# JWT_SECRET
```

### Type Bindings

```typescript
// src/types.ts
export interface Env {
  // Variables
  ENVIRONMENT: string
  API_VERSION: string

  // Secrets (set via wrangler secret put)
  STRIPE_SECRET_KEY: string
  JWT_SECRET: string

  // Bindings
  DB: D1Database
  KV: KVNamespace
  BUCKET: R2Bucket
}
```

### With Hono

```typescript
// src/index.ts
import { Hono } from 'hono'
import type { Env } from './types'

const app = new Hono<{ Bindings: Env }>()

app.get('/config', (c) => {
  return c.json({
    environment: c.env.ENVIRONMENT,
    apiVersion: c.env.API_VERSION,
  })
})

app.post('/checkout', async (c) => {
  // Access secret
  const stripe = new Stripe(c.env.STRIPE_SECRET_KEY)
  // ...
})

export default app
```

### Setting Secrets

```bash
# Set secret
wrangler secret put JWT_SECRET
# Enter value when prompted

# Set secret for specific environment
wrangler secret put JWT_SECRET --env production

# List secrets
wrangler secret list
```

---

## Environment-Specific Config

### Next.js

```typescript
// lib/config.ts
const config = {
  development: {
    apiUrl: 'http://localhost:3000/api',
    debug: true,
  },
  production: {
    apiUrl: 'https://api.example.com',
    debug: false,
  },
  test: {
    apiUrl: 'http://localhost:3000/api',
    debug: true,
  },
} as const

export const appConfig = config[process.env.NODE_ENV || 'development']
```

### Cloudflare Workers

```toml
# wrangler.toml

[vars]
ENVIRONMENT = "development"

[env.staging]
vars = { ENVIRONMENT = "staging" }

[env.production]
vars = { ENVIRONMENT = "production" }
```

```bash
# Deploy to environment
wrangler deploy --env staging
wrangler deploy --env production
```

---

## .env Files

### Example .env.example

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/mydb

# Authentication
JWT_SECRET=your-jwt-secret-at-least-32-characters
CLERK_SECRET_KEY=sk_test_...
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...

# Payments
STRIPE_SECRET_KEY=sk_test_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...

# Email
RESEND_API_KEY=re_...

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### .gitignore

```gitignore
# Environment files
.env
.env.local
.env.*.local

# Keep example
!.env.example
```

---

## Vercel Environment Variables

### Via Dashboard

1. Go to Project Settings → Environment Variables
2. Add variables for each environment (Production, Preview, Development)
3. Mark sensitive values as "Sensitive"

### Via CLI

```bash
# Add variable
vercel env add DATABASE_URL production

# Pull to local
vercel env pull .env.local

# List variables
vercel env ls
```

### vercel.json

```json
{
  "env": {
    "CUSTOM_VAR": "value"
  },
  "build": {
    "env": {
      "BUILD_TIME_VAR": "value"
    }
  }
}
```

---

## Best Practices

### Do

- Validate env vars at startup with Zod
- Use `.env.example` as documentation
- Use `NEXT_PUBLIC_` prefix only for client-safe values
- Store secrets in Vercel/Cloudflare dashboard, not files
- Use different values per environment

### Don't

- Commit `.env` files with secrets
- Use `NEXT_PUBLIC_` for sensitive values
- Hardcode environment-specific values
- Access `process.env` directly without validation
- Share secrets between environments

### Security

```typescript
// NEVER expose server secrets to client
// This runs on server only
const secret = process.env.JWT_SECRET ✓

// This is exposed to browser bundle
const secret = process.env.NEXT_PUBLIC_JWT_SECRET ✗
```

---

## Runtime vs Build Time

### Next.js

```typescript
// Build time - baked into bundle
const apiUrl = process.env.NEXT_PUBLIC_API_URL

// Runtime - read on each request (Server Components only)
const secret = process.env.JWT_SECRET
```

### Dynamic Runtime Config

```typescript
// next.config.js
module.exports = {
  // These are available at runtime via process.env
  serverRuntimeConfig: {
    jwtSecret: process.env.JWT_SECRET,
  },
  // These are available on both server and client
  publicRuntimeConfig: {
    apiUrl: process.env.NEXT_PUBLIC_API_URL,
  },
}

// Usage
import getConfig from 'next/config'
const { serverRuntimeConfig, publicRuntimeConfig } = getConfig()
```
