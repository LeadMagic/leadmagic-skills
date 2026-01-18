---
title: Secure API Key Management
impact: CRITICAL
impactDescription: Prevents credential leakage and unauthorized access
tags: authentication, api-keys, security
---

## Secure API Key Management

API keys must be transmitted securely, validated properly, and managed with proper lifecycle controls.

**Incorrect (insecure key handling):**

```typescript
// API key in URL - logged, cached, leaked in referrer
GET /api/users?api_key=sk_live_abc123

// API key in custom header without standard prefix
const apiKey = request.headers.get('X-Api-Key')

// Storing full key in database (can be stolen)
await db.apiKeys.create({ key: 'sk_live_abc123...' })

// No key rotation or expiration
const keyData = await db.apiKeys.findByKey(apiKey)
// Uses key forever without checking expiration
```

**Correct (secure key handling):**

```typescript
// API key in Authorization header with Bearer prefix
const authHeader = request.headers.get('Authorization')
if (!authHeader?.startsWith('Bearer ')) {
  return errorResponse(401, 'UNAUTHORIZED', 'Missing Authorization header')
}
const apiKey = authHeader.slice(7)

// Store only hashed keys
import { createHash } from 'crypto'

function hashApiKey(key: string): string {
  return createHash('sha256').update(key).digest('hex')
}

// Create key with hash stored, full key returned once
async function createApiKey(userId: string, name: string) {
  const keyId = crypto.randomUUID().replace(/-/g, '')
  const secret = crypto.randomBytes(24).toString('base64url')
  const fullKey = `sk_live_${keyId}_${secret}`

  await db.apiKeys.create({
    id: keyId,
    userId,
    name,
    keyHash: hashApiKey(fullKey),
    prefix: fullKey.slice(0, 12),  // For display: sk_live_xxxx...
    createdAt: new Date(),
    expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
  })

  // Return full key ONCE - cannot be retrieved again
  return { key: fullKey, expiresAt: keyData.expiresAt }
}

// Validate with hash comparison
async function validateApiKey(apiKey: string) {
  const keyHash = hashApiKey(apiKey)

  const keyData = await db.apiKeys.findOne({
    where: { keyHash },
    include: { user: true },
  })

  if (!keyData) {
    return null
  }

  // Check expiration
  if (keyData.expiresAt && keyData.expiresAt < new Date()) {
    return null
  }

  // Check if revoked
  if (keyData.revokedAt) {
    return null
  }

  // Update last used timestamp
  await db.apiKeys.update({
    where: { id: keyData.id },
    data: { lastUsedAt: new Date() },
  })

  return {
    id: keyData.id,
    userId: keyData.userId,
    scopes: keyData.scopes,
    tier: keyData.user.tier,
  }
}
```

**Key Lifecycle:**

```typescript
// Revoke key (soft delete for audit trail)
async function revokeApiKey(keyId: string, userId: string, reason: string) {
  await db.apiKeys.update({
    where: { id: keyId, userId },
    data: {
      revokedAt: new Date(),
      revokedReason: reason,
    },
  })
}

// Rotate key (create new, schedule old for deletion)
async function rotateApiKey(oldKeyId: string, userId: string) {
  const newKey = await createApiKey(userId, 'Rotated key')

  // Give grace period for old key
  await db.apiKeys.update({
    where: { id: oldKeyId },
    data: {
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24h grace
    },
  })

  return newKey
}
```

**Key Best Practices:**

- Never log full API keys
- Use `sk_live_` prefix for production, `sk_test_` for sandbox
- Implement rate limiting per key
- Track last used timestamp for inactive key cleanup
- Allow users to manage their own keys (create, revoke, view usage)
- Support multiple keys per user for different integrations
