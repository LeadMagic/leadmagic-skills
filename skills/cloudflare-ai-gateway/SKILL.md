---
name: cloudflare-ai-gateway
description: Best practices for using Cloudflare AI Gateway for unified AI API management. Use when routing requests to AI providers, implementing caching, rate limiting, observability, or managing API keys securely. Triggers on "AI Gateway", "LLM routing", "AI caching", "model fallback", "AI observability".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
  context7: cloudflare/workers-sdk
---

# Cloudflare AI Gateway Best Practices

Comprehensive guide for managing AI API requests through Cloudflare AI Gateway.

## When to Apply

Reference these guidelines when:
- Routing requests to multiple AI providers (OpenAI, Anthropic, etc.)
- Implementing caching for AI responses
- Setting up rate limiting and cost controls
- Adding observability to AI requests
- Managing API keys securely with BYOK

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Routing | CRITICAL | `routing-` |
| 2 | Caching | HIGH | `cache-` |
| 3 | Security | HIGH | `security-` |

## Quick Reference

### 1. Routing (CRITICAL)

- `routing-fallbacks` - Configure fallback providers for reliability

### 2. Caching (HIGH)

- `cache-semantic` - Enable semantic caching for similar prompts

### 3. Security (HIGH)

- `security-guardrails` - Enable content guardrails
- `ratelimit-quotas` - Implement usage quotas

### 5. Observability (MEDIUM)

- `observe-logging` - Enable request/response logging
- `observe-metrics` - Track usage metrics
- `observe-alerts` - Set up cost/error alerts
- `observe-analytics` - Analyze usage patterns

## Essential Patterns

### Basic AI Gateway Setup

```typescript
import { Hono } from 'hono'

type Bindings = {
  AI_GATEWAY_TOKEN: string
  OPENAI_API_KEY: string
  ANTHROPIC_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

// AI Gateway base URL
const AI_GATEWAY_URL = 'https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_name}'

app.post('/chat', async (c) => {
  const { messages, model = 'gpt-4' } = await c.req.json()

  // Route through AI Gateway (OpenAI compatible endpoint)
  const response = await fetch(`${AI_GATEWAY_URL}/openai/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${c.env.OPENAI_API_KEY}`,
      // AI Gateway specific headers
      'cf-aig-cache-ttl': '3600',           // Cache for 1 hour
      'cf-aig-skip-cache': 'false',
      'cf-aig-metadata': JSON.stringify({    // Custom metadata for logging
        userId: c.req.header('X-User-Id'),
        feature: 'chat',
      }),
    },
    body: JSON.stringify({
      model,
      messages,
      max_tokens: 1000,
    }),
  })

  return new Response(response.body, {
    headers: {
      'Content-Type': 'application/json',
      // Pass through rate limit headers
      'X-RateLimit-Remaining': response.headers.get('cf-aig-ratelimit-remaining') ?? '',
    },
  })
})
```

### Unified Compatible Endpoint

```typescript
// Use unified endpoint - switch providers by changing model name
app.post('/ai/chat', async (c) => {
  const { messages, provider = 'openai', model } = await c.req.json()

  // Provider-specific API keys
  const apiKeys: Record<string, string> = {
    openai: c.env.OPENAI_API_KEY,
    anthropic: c.env.ANTHROPIC_API_KEY,
    'workers-ai': c.env.CF_API_TOKEN,
  }

  // Model mapping
  const models: Record<string, string> = {
    'gpt-4': 'gpt-4-turbo-preview',
    'claude-3': 'claude-3-opus-20240229',
    'llama': '@cf/meta/llama-2-7b-chat-int8',
  }

  // Use /compat endpoint for OpenAI-compatible interface
  const response = await fetch(`${AI_GATEWAY_URL}/${provider}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKeys[provider]}`,
    },
    body: JSON.stringify({
      model: models[model] ?? model,
      messages,
    }),
  })

  return new Response(response.body, {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

### Fallback Configuration

```typescript
// Implement fallback chain for reliability
async function callWithFallback(
  messages: Message[],
  env: Bindings
): Promise<Response> {
  const providers = [
    {
      name: 'openai',
      model: 'gpt-4-turbo-preview',
      apiKey: env.OPENAI_API_KEY,
    },
    {
      name: 'anthropic',
      model: 'claude-3-opus-20240229',
      apiKey: env.ANTHROPIC_API_KEY,
    },
    {
      name: 'workers-ai',
      model: '@cf/meta/llama-2-7b-chat-int8',
      apiKey: env.CF_API_TOKEN,
    },
  ]

  let lastError: Error | null = null

  for (const provider of providers) {
    try {
      const response = await fetch(
        `${AI_GATEWAY_URL}/${provider.name}/chat/completions`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${provider.apiKey}`,
            'cf-aig-cache-ttl': '3600',
          },
          body: JSON.stringify({
            model: provider.model,
            messages,
          }),
        }
      )

      if (response.ok) {
        return response
      }

      // If rate limited or server error, try next provider
      if (response.status === 429 || response.status >= 500) {
        lastError = new Error(`${provider.name}: ${response.status}`)
        continue
      }

      // Client error - don't fallback
      return response
    } catch (err) {
      lastError = err as Error
      continue
    }
  }

  throw lastError ?? new Error('All providers failed')
}
```

### Streaming Responses

```typescript
app.post('/chat/stream', async (c) => {
  const { messages, model } = await c.req.json()

  const response = await fetch(`${AI_GATEWAY_URL}/openai/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${c.env.OPENAI_API_KEY}`,
    },
    body: JSON.stringify({
      model,
      messages,
      stream: true,  // Enable streaming
    }),
  })

  // Return streaming response directly
  return new Response(response.body, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  })
})

// Parse SSE stream
async function* parseSSEStream(response: Response) {
  const reader = response.body?.getReader()
  if (!reader) return

  const decoder = new TextDecoder()
  let buffer = ''

  while (true) {
    const { done, value } = await reader.read()
    if (done) break

    buffer += decoder.decode(value, { stream: true })
    const lines = buffer.split('\n')
    buffer = lines.pop() ?? ''

    for (const line of lines) {
      if (line.startsWith('data: ')) {
        const data = line.slice(6)
        if (data === '[DONE]') return
        yield JSON.parse(data)
      }
    }
  }
}
```

### Caching Strategies

```typescript
app.post('/ai/cached', async (c) => {
  const { messages, cacheStrategy = 'default' } = await c.req.json()

  const cacheHeaders: Record<string, string> = {}

  switch (cacheStrategy) {
    case 'aggressive':
      // Cache for 24 hours
      cacheHeaders['cf-aig-cache-ttl'] = '86400'
      break

    case 'short':
      // Cache for 5 minutes
      cacheHeaders['cf-aig-cache-ttl'] = '300'
      break

    case 'none':
      // Skip cache entirely
      cacheHeaders['cf-aig-skip-cache'] = 'true'
      break

    default:
      // Default: 1 hour
      cacheHeaders['cf-aig-cache-ttl'] = '3600'
  }

  const response = await fetch(`${AI_GATEWAY_URL}/openai/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${c.env.OPENAI_API_KEY}`,
      ...cacheHeaders,
    },
    body: JSON.stringify({ model: 'gpt-4', messages }),
  })

  const cacheHit = response.headers.get('cf-aig-cache-status') === 'HIT'

  return c.json({
    ...(await response.json()),
    _meta: { cacheHit },
  })
})
```

### Rate Limiting by User

```typescript
app.post('/ai/chat', async (c) => {
  const userId = c.req.header('X-User-Id')
  const { messages } = await c.req.json()

  // Check user's rate limit status from AI Gateway
  const response = await fetch(`${AI_GATEWAY_URL}/openai/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${c.env.OPENAI_API_KEY}`,
      // Rate limit by user ID
      'cf-aig-ratelimit-key': userId ?? 'anonymous',
    },
    body: JSON.stringify({ model: 'gpt-4', messages }),
  })

  // Check rate limit headers
  const remaining = response.headers.get('cf-aig-ratelimit-remaining')
  const resetAt = response.headers.get('cf-aig-ratelimit-reset')

  if (response.status === 429) {
    return c.json({
      error: 'Rate limit exceeded',
      resetAt,
    }, 429)
  }

  const data = await response.json()

  return c.json({
    ...data,
    _ratelimit: {
      remaining: parseInt(remaining ?? '0'),
      resetAt,
    },
  })
})
```

### Observability & Logging

```typescript
app.post('/ai/chat', async (c) => {
  const userId = c.req.header('X-User-Id')
  const { messages, feature } = await c.req.json()

  const startTime = Date.now()

  const response = await fetch(`${AI_GATEWAY_URL}/openai/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${c.env.OPENAI_API_KEY}`,
      // Custom metadata for AI Gateway logs
      'cf-aig-metadata': JSON.stringify({
        userId,
        feature,
        environment: c.env.ENVIRONMENT,
        requestId: crypto.randomUUID(),
      }),
      // Enable logging
      'cf-aig-log-request': 'true',
      'cf-aig-log-response': 'true',
    },
    body: JSON.stringify({ model: 'gpt-4', messages }),
  })

  const latency = Date.now() - startTime
  const data = await response.json()

  // Log to Analytics Engine
  c.env.ANALYTICS.writeDataPoint({
    blobs: [userId ?? 'anonymous', feature],
    doubles: [
      latency,
      data.usage?.total_tokens ?? 0,
      data.usage?.prompt_tokens ?? 0,
      data.usage?.completion_tokens ?? 0,
    ],
    indexes: [feature],
  })

  return c.json(data)
})
```

## Gateway Configuration (Dashboard)

Configure these settings in the Cloudflare Dashboard:

### Rate Limiting
```
Requests per minute: 60
Requests per day: 10000
Rate limit key: cf-aig-ratelimit-key header
```

### Caching
```
Default TTL: 3600 seconds
Semantic caching: Enabled
Cache similar prompts: 0.95 similarity threshold
```

### Guardrails
```
Prompt injection detection: Enabled
PII detection: Enabled (redact)
Toxicity filter: Enabled
Custom blocklist: [list of blocked terms]
```

## AI Gateway Limits

| Resource | Limit |
|----------|-------|
| Requests per minute | Configurable |
| Max request size | 100MB |
| Max response size | 100MB |
| Cache TTL max | 30 days |
| Log retention | 7-30 days |

## Supported Providers

- OpenAI (GPT-4, GPT-3.5)
- Anthropic (Claude 3)
- Google (Gemini)
- Cohere
- Hugging Face
- Azure OpenAI
- Amazon Bedrock
- Workers AI (Cloudflare)

