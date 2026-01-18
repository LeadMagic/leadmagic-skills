---
title: Configure Fallback Providers for Reliability
impact: CRITICAL
impactDescription: Ensures AI requests succeed even when primary provider is down
tags: routing, fallbacks, reliability, providers
---

## Configure Fallback Providers for Reliability

Implement a fallback chain to automatically route to backup providers when the primary fails. This ensures your AI features remain available.

**Incorrect (single provider, no fallback):**

```typescript
app.post('/chat', async (c) => {
  const { messages } = await c.req.json()

  // ❌ If OpenAI is down or rate limited, users get errors
  const response = await fetch(`${AI_GATEWAY_URL}/openai/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${c.env.OPENAI_API_KEY}`,
    },
    body: JSON.stringify({ model: 'gpt-4', messages }),
  })

  if (!response.ok) {
    return c.json({ error: 'AI service unavailable' }, 503)
  }

  return c.json(await response.json())
})
```

**Correct (fallback chain with multiple providers):**

```typescript
interface Provider {
  name: string
  endpoint: string
  model: string
  getApiKey: (env: Bindings) => string
  transformRequest?: (body: any) => any
  transformResponse?: (body: any) => any
}

const PROVIDERS: Provider[] = [
  {
    name: 'openai',
    endpoint: 'openai/chat/completions',
    model: 'gpt-4-turbo-preview',
    getApiKey: (env) => env.OPENAI_API_KEY,
  },
  {
    name: 'anthropic',
    endpoint: 'anthropic/v1/messages',
    model: 'claude-3-opus-20240229',
    getApiKey: (env) => env.ANTHROPIC_API_KEY,
    transformRequest: (body) => ({
      model: body.model,
      max_tokens: body.max_tokens ?? 1024,
      messages: body.messages,
    }),
    transformResponse: (body) => ({
      choices: [{
        message: {
          role: 'assistant',
          content: body.content[0].text,
        },
      }],
      usage: {
        prompt_tokens: body.usage.input_tokens,
        completion_tokens: body.usage.output_tokens,
        total_tokens: body.usage.input_tokens + body.usage.output_tokens,
      },
    }),
  },
  {
    name: 'workers-ai',
    endpoint: 'workers-ai/@cf/meta/llama-2-7b-chat-int8',
    model: '@cf/meta/llama-2-7b-chat-int8',
    getApiKey: (env) => env.CF_API_TOKEN,
  },
]

async function callWithFallback(
  messages: Message[],
  env: Bindings,
  options: {
    maxTokens?: number
    preferredProvider?: string
  } = {}
): Promise<{ response: any; provider: string }> {
  const providers = options.preferredProvider
    ? [
        ...PROVIDERS.filter(p => p.name === options.preferredProvider),
        ...PROVIDERS.filter(p => p.name !== options.preferredProvider),
      ]
    : PROVIDERS

  const errors: Array<{ provider: string; error: string }> = []

  for (const provider of providers) {
    try {
      const requestBody = {
        model: provider.model,
        messages,
        max_tokens: options.maxTokens ?? 1024,
      }

      const finalBody = provider.transformRequest
        ? provider.transformRequest(requestBody)
        : requestBody

      const response = await fetch(
        `${AI_GATEWAY_URL}/${provider.endpoint}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${provider.getApiKey(env)}`,
            'cf-aig-cache-ttl': '3600',
          },
          body: JSON.stringify(finalBody),
        }
      )

      // Rate limited or server error - try next provider
      if (response.status === 429) {
        errors.push({ provider: provider.name, error: 'Rate limited' })
        continue
      }

      if (response.status >= 500) {
        errors.push({ provider: provider.name, error: `Server error: ${response.status}` })
        continue
      }

      // Client error - don't fallback, return error
      if (!response.ok) {
        const errorBody = await response.text()
        return {
          response: { error: errorBody },
          provider: provider.name,
        }
      }

      let responseBody = await response.json()

      // Transform response to common format
      if (provider.transformResponse) {
        responseBody = provider.transformResponse(responseBody)
      }

      return {
        response: responseBody,
        provider: provider.name,
      }
    } catch (err) {
      errors.push({
        provider: provider.name,
        error: err instanceof Error ? err.message : 'Unknown error',
      })
      continue
    }
  }

  // All providers failed
  throw new Error(`All providers failed: ${JSON.stringify(errors)}`)
}

// Usage
app.post('/chat', async (c) => {
  const { messages, preferredProvider } = await c.req.json()

  try {
    const { response, provider } = await callWithFallback(
      messages,
      c.env,
      { preferredProvider }
    )

    return c.json({
      ...response,
      _meta: {
        provider,
        fallbackUsed: provider !== (preferredProvider ?? 'openai'),
      },
    })
  } catch (err) {
    return c.json({
      error: 'All AI providers unavailable',
      details: err instanceof Error ? err.message : 'Unknown error',
    }, 503)
  }
})
```

**Gateway-level fallbacks (Dashboard config):**

Configure fallback rules in the AI Gateway dashboard for automatic routing:

```json
{
  "routing_rules": [
    {
      "condition": "provider.status >= 500",
      "action": "fallback",
      "target": "anthropic"
    },
    {
      "condition": "provider.status == 429",
      "action": "fallback",
      "target": "workers-ai"
    }
  ]
}
```

**Best practices:**
- Order providers by preference (cost, quality, speed)
- Include at least one highly-available fallback (Workers AI)
- Log which provider was used for monitoring
- Consider cost differences between providers
