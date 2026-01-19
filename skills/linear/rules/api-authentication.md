---
title: Linear API Authentication
impact: CRITICAL
impactDescription: Required for all API operations
tags: api, authentication, security, sdk
---

## Linear API Authentication

Proper authentication setup is required for all Linear API operations. Choose the right method based on your use case.

**Incorrect (hardcoded API key):**

```typescript
// Never hardcode API keys
const linear = new LinearClient({
  apiKey: 'lin_api_xxxxxxxxxxxxxxxxxx'
})
```

**Correct (environment variable):**

```typescript
import { LinearClient } from '@linear/sdk'

// Server-side: Use API key from environment
const linear = new LinearClient({
  apiKey: process.env.LINEAR_API_KEY!
})

// Validate key exists
if (!process.env.LINEAR_API_KEY) {
  throw new Error('LINEAR_API_KEY environment variable is required')
}
```

## Authentication Methods

### 1. Personal API Key (Server-side)

Best for: Backend services, scripts, CI/CD automation

```typescript
// Generate at: Linear Settings → API → Personal API keys
const linear = new LinearClient({
  apiKey: process.env.LINEAR_API_KEY
})
```

### 2. OAuth 2.0 (User-facing apps)

Best for: Apps that act on behalf of users

```typescript
// 1. Redirect user to authorize
const authUrl = `https://linear.app/oauth/authorize?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&response_type=code&scope=read,write`

// 2. Exchange code for token
const tokenResponse = await fetch('https://api.linear.app/oauth/token', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams({
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    redirect_uri: REDIRECT_URI,
    code: authorizationCode,
    grant_type: 'authorization_code',
  }),
})

const { access_token } = await tokenResponse.json()

// 3. Use token
const linear = new LinearClient({ accessToken: access_token })
```

### 3. Webhook Signature Verification

Best for: Validating incoming webhooks

```typescript
import crypto from 'crypto'

function verifyLinearWebhook(
  body: string,
  signature: string,
  secret: string
): boolean {
  const hmac = crypto.createHmac('sha256', secret)
  hmac.update(body)
  const expectedSignature = hmac.digest('hex')
  
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expectedSignature)
  )
}
```

## Environment Setup

```bash
# .env.local (development)
LINEAR_API_KEY=lin_api_xxxxxxxxxxxxx
LINEAR_TEAM_ID=your-team-id
LINEAR_WEBHOOK_SECRET=whsec_xxxxx

# .env.production
# Use secrets manager (Doppler, Vault, etc.)
```

## Permission Scopes

| Scope | Description |
|-------|-------------|
| `read` | Read issues, projects, users, teams |
| `write` | Create/update issues, comments, labels |
| `issues:create` | Create issues only |
| `admin` | Team and workspace settings |

## Error Handling

```typescript
try {
  const issue = await linear.createIssue({ ... })
} catch (error) {
  if (error.response?.status === 401) {
    // Invalid or expired token
    throw new Error('Linear authentication failed')
  }
  if (error.response?.status === 403) {
    // Insufficient permissions
    throw new Error('Insufficient Linear permissions')
  }
  throw error
}
```

## Rate Limiting

Linear API has rate limits. Handle gracefully:

```typescript
const MAX_RETRIES = 3
const RETRY_DELAY = 1000

async function linearWithRetry<T>(
  operation: () => Promise<T>,
  retries = MAX_RETRIES
): Promise<T> {
  try {
    return await operation()
  } catch (error) {
    if (error.response?.status === 429 && retries > 0) {
      await new Promise(r => setTimeout(r, RETRY_DELAY * (MAX_RETRIES - retries + 1)))
      return linearWithRetry(operation, retries - 1)
    }
    throw error
  }
}
```
