---
title: Edge Runtime for AI Routes
impact: MEDIUM
impactDescription: Lower latency, global distribution
tags: edge, runtime, performance, streaming
---

## Edge Runtime for AI Routes

AI SDK routes can run on the edge for lower latency streaming. Use edge runtime when your route doesn't need Node.js-specific APIs.

**Edge-Compatible Route:**

```typescript
// app/api/chat/route.ts
import { openai } from '@ai-sdk/openai'
import { streamText } from 'ai'

// Enable edge runtime
export const runtime = 'edge'

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    // Edge benefits: faster first byte, lower latency globally
  })

  return result.toDataStreamResponse()
}
```

**When to Use Edge vs Node.js:**

```typescript
// ✅ Good for Edge:
// - Simple streaming responses
// - No database access needed
// - No Node.js-specific packages
export const runtime = 'edge'

export async function POST(req: Request) {
  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
  })
  return result.toDataStreamResponse()
}

// ✅ Use Node.js when you need:
// - Database queries (Prisma, Drizzle)
// - File system access
// - Node.js-specific packages
// - Heavy computation
export const runtime = 'nodejs' // or omit (default)

export async function POST(req: Request) {
  const { messages, userId } = await req.json()

  // Database access requires Node.js runtime
  const user = await db.user.findUnique({ where: { id: userId } })

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    system: `You are helping ${user.name}...`,
  })

  return result.toDataStreamResponse()
}
```

**Edge with External Database:**

```typescript
// Edge can use HTTP-based database clients
import { openai } from '@ai-sdk/openai'
import { streamText } from 'ai'
import { neon } from '@neondatabase/serverless' // HTTP-based

export const runtime = 'edge'

const sql = neon(process.env.DATABASE_URL!)

export async function POST(req: Request) {
  const { messages, userId } = await req.json()

  // HTTP-based query works on edge
  const [user] = await sql`SELECT * FROM users WHERE id = ${userId}`

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    system: `You are helping ${user.name}...`,
  })

  return result.toDataStreamResponse()
}
```

**Edge with KV/Redis:**

```typescript
import { openai } from '@ai-sdk/openai'
import { streamText } from 'ai'
import { kv } from '@vercel/kv'

export const runtime = 'edge'

export async function POST(req: Request) {
  const { messages, sessionId } = await req.json()

  // Get conversation context from KV
  const context = await kv.get<string>(`chat:${sessionId}:context`)

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    system: context || 'You are a helpful assistant.',
    onFinish: async ({ text }) => {
      // Update context in KV
      await kv.set(`chat:${sessionId}:context`, text.slice(-1000))
    },
  })

  return result.toDataStreamResponse()
}
```

**Streaming Duration on Edge:**

```typescript
// Edge functions have default 30s timeout
// Extend for long AI generations

export const runtime = 'edge'
export const maxDuration = 60 // Up to 60s on Pro, 300s on Enterprise

export async function POST(req: Request) {
  // Long generation is now allowed
  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    maxTokens: 4000, // May take longer
  })

  return result.toDataStreamResponse()
}
```

**Edge Function Size Limits:**

```typescript
// Edge has 1-4MB bundle size limit
// Avoid importing large packages

// ❌ Bad: Large import
import { createCanvas } from 'canvas' // Node.js only, large

// ✅ Good: Minimal imports
import { openai } from '@ai-sdk/openai'
import { streamText } from 'ai'

// For large dependencies, use Node.js runtime or
// split into separate API routes
```

**Hybrid Approach:**

```typescript
// Lightweight edge route for streaming
// app/api/chat/route.ts
export const runtime = 'edge'

export async function POST(req: Request) {
  const result = streamText({ ... })
  return result.toDataStreamResponse()
}

// Heavy Node.js route for tool execution
// app/api/tools/route.ts
export const runtime = 'nodejs'

export async function POST(req: Request) {
  const { tool, args } = await req.json()

  // Database queries, file processing, etc.
  const result = await executeHeavyTool(tool, args)

  return Response.json(result)
}
```

**Edge Runtime Checklist:**

| Compatible | Not Compatible |
|------------|----------------|
| fetch, Request, Response | fs, path, child_process |
| crypto.subtle | Node.js crypto (use crypto.subtle) |
| TextEncoder/Decoder | Buffer (use Uint8Array) |
| @vercel/kv, @vercel/edge-config | Prisma, Drizzle |
| HTTP-based DB clients | TCP-based connections |
| AI SDK (all providers) | Heavy image processing |
