---
title: Enable Semantic Caching for Similar Prompts
impact: HIGH
impactDescription: Reduces costs and latency by caching semantically similar requests
tags: caching, performance, cost, semantic
---

## Enable Semantic Caching for Similar Prompts

Use AI Gateway's semantic caching to return cached responses for prompts that are semantically similar, not just exact matches. This dramatically reduces costs and improves latency.

**Without semantic caching (exact match only):**

```typescript
// These are treated as different requests (no cache hit):
// "What is the capital of France?"
// "what's the capital of france"
// "Tell me the capital of France"
// "What is France's capital?"

// Only exact string matches return cached responses
```

**With semantic caching enabled:**

```typescript
app.post('/chat', async (c) => {
  const { messages, cacheConfig } = await c.req.json()

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${c.env.OPENAI_API_KEY}`,
  }

  // ✅ Enable semantic caching with similarity threshold
  if (cacheConfig?.semantic) {
    headers['cf-aig-cache-ttl'] = String(cacheConfig.ttl ?? 3600)
    headers['cf-aig-semantic-cache'] = 'true'
    // Similarity threshold: 0.95 = 95% similar prompts will cache hit
    headers['cf-aig-semantic-cache-threshold'] = String(cacheConfig.threshold ?? 0.95)
  }

  const response = await fetch(`${AI_GATEWAY_URL}/openai/chat/completions`, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      model: 'gpt-4',
      messages,
    }),
  })

  // Check if response came from cache
  const cacheStatus = response.headers.get('cf-aig-cache-status')
  const wasCached = cacheStatus === 'HIT'

  return c.json({
    ...(await response.json()),
    _cache: {
      hit: wasCached,
      status: cacheStatus,
    },
  })
})
```

**Cache configuration strategies:**

```typescript
type CacheStrategy = 'none' | 'exact' | 'semantic-strict' | 'semantic-loose'

function getCacheHeaders(strategy: CacheStrategy): Record<string, string> {
  switch (strategy) {
    case 'none':
      return {
        'cf-aig-skip-cache': 'true',
      }

    case 'exact':
      // Only exact prompt matches
      return {
        'cf-aig-cache-ttl': '3600',
        'cf-aig-semantic-cache': 'false',
      }

    case 'semantic-strict':
      // High similarity required (95%)
      // Good for: factual queries, documentation lookups
      return {
        'cf-aig-cache-ttl': '86400', // 24 hours
        'cf-aig-semantic-cache': 'true',
        'cf-aig-semantic-cache-threshold': '0.95',
      }

    case 'semantic-loose':
      // Lower similarity threshold (85%)
      // Good for: FAQ, common questions
      return {
        'cf-aig-cache-ttl': '86400',
        'cf-aig-semantic-cache': 'true',
        'cf-aig-semantic-cache-threshold': '0.85',
      }
  }
}

// Use different strategies per endpoint
app.post('/ai/faq', async (c) => {
  // FAQ responses are stable, use loose semantic caching
  const headers = getCacheHeaders('semantic-loose')
  // ...
})

app.post('/ai/code-review', async (c) => {
  // Code review needs precision, use strict caching
  const headers = getCacheHeaders('semantic-strict')
  // ...
})

app.post('/ai/creative', async (c) => {
  // Creative writing should never cache
  const headers = getCacheHeaders('none')
  // ...
})
```

**Per-request cache control:**

```typescript
app.post('/chat', async (c) => {
  const { messages, skipCache, cacheTtl } = await c.req.json()

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${c.env.OPENAI_API_KEY}`,
  }

  // Allow clients to skip cache for fresh responses
  if (skipCache) {
    headers['cf-aig-skip-cache'] = 'true'
  } else {
    headers['cf-aig-cache-ttl'] = String(cacheTtl ?? 3600)
    headers['cf-aig-semantic-cache'] = 'true'
  }

  const response = await fetch(`${AI_GATEWAY_URL}/openai/chat/completions`, {
    method: 'POST',
    headers,
    body: JSON.stringify({ model: 'gpt-4', messages }),
  })

  return new Response(response.body, { headers: response.headers })
})
```

**When to skip caching:**

| Use Case | Cache Strategy |
|----------|----------------|
| FAQ / Help content | Semantic (loose) |
| Code generation | Semantic (strict) or exact |
| Factual queries | Semantic (strict) |
| Creative writing | No cache |
| Personalized responses | No cache |
| Real-time data queries | No cache |
| Conversations (context-dependent) | Exact only |

**Cost savings example:**

```
Without caching:
- 10,000 similar FAQ questions/day
- ~$0.03 per request = $300/day

With semantic caching (80% hit rate):
- 2,000 unique requests = $60/day
- Savings: $240/day = $7,200/month
```
