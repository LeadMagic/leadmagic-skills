---
title: Match Server and Client maxSteps Configuration
impact: CRITICAL
impactDescription: Prevents silent tool execution failures
tags: streaming, tools, configuration
---

## Match Server and Client maxSteps Configuration

When using tool calling with `useChat` and `streamText`, the `maxSteps` configuration must match on both client and server. Mismatched values cause tools to silently fail.

**Incorrect (mismatched maxSteps):**

```typescript
// Client: app/page.tsx
'use client'
import { useChat } from 'ai/react'

export function Chat() {
  const { messages, ... } = useChat({
    api: '/api/chat',
    maxSteps: 3, // Client allows 3 steps
  })
  // ...
}

// Server: app/api/chat/route.ts
import { streamText } from 'ai'

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    maxSteps: 10, // Server allows 10 steps - MISMATCH!
    tools: { /* ... */ },
  })

  return result.toDataStreamResponse()
}
```

**Correct (matching maxSteps):**

```typescript
// Shared config: lib/ai-config.ts
export const AI_CONFIG = {
  maxSteps: 5,
} as const

// Client: app/page.tsx
'use client'
import { useChat } from 'ai/react'
import { AI_CONFIG } from '@/lib/ai-config'

export function Chat() {
  const { messages, ... } = useChat({
    api: '/api/chat',
    maxSteps: AI_CONFIG.maxSteps, // Use shared config
  })
  // ...
}

// Server: app/api/chat/route.ts
import { streamText } from 'ai'
import { AI_CONFIG } from '@/lib/ai-config'

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    maxSteps: AI_CONFIG.maxSteps, // Use same shared config
    tools: { /* ... */ },
  })

  return result.toDataStreamResponse()
}
```

Best practice: Define AI configuration in a shared module and import it in both client and server code. This ensures consistency and makes configuration changes easier.
