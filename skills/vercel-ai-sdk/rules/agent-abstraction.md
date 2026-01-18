---
title: Use Agent Abstraction for Reusable AI Logic
impact: HIGH
impactDescription: Cleaner, reusable agent definitions across contexts
tags: agents, architecture, reusability
---

## Use Agent Abstraction for Reusable AI Logic

AI SDK 6 introduces the `Agent` interface and `ToolLoopAgent` for building reusable agents. Define agents once and use them across chat UIs, API routes, and background jobs.

**Incorrect (duplicated agent logic):**

```typescript
// app/api/chat/route.ts
export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: openai('gpt-4-turbo'),
    system: 'You are a helpful research assistant...',
    messages,
    tools: {
      search: searchTool,
      summarize: summarizeTool,
    },
    maxSteps: 10,
  })

  return result.toDataStreamResponse()
}

// app/api/research/route.ts - Duplicated!
export async function POST(req: Request) {
  const { query } = await req.json()

  const result = await generateText({
    model: openai('gpt-4-turbo'),
    system: 'You are a helpful research assistant...',  // Same again
    prompt: query,
    tools: {
      search: searchTool,
      summarize: summarizeTool,  // Same tools
    },
    maxSteps: 10,
  })

  return Response.json({ result: result.text })
}
```

**Correct (using Agent abstraction):**

```typescript
// lib/agents/research-agent.ts
import { openai } from '@ai-sdk/openai'
import { tool } from 'ai'
import { z } from 'zod'

// Define tools separately for reuse
const searchTool = tool({
  description: 'Search the web for information',
  parameters: z.object({
    query: z.string(),
  }),
  execute: async ({ query }) => {
    // Search implementation
    return { results: [] }
  },
})

const summarizeTool = tool({
  description: 'Summarize a piece of text',
  parameters: z.object({
    text: z.string(),
    maxLength: z.number().optional(),
  }),
  execute: async ({ text, maxLength }) => {
    // Summarization implementation
    return { summary: '' }
  },
})

// Define the reusable agent
export const researchAgent = {
  model: openai('gpt-4-turbo'),
  system: `You are a helpful research assistant.
    Use the search tool to find information.
    Use the summarize tool to condense long content.
    Always cite your sources.`,
  tools: {
    search: searchTool,
    summarize: summarizeTool,
  },
  maxSteps: 10,
} as const

// app/api/chat/route.ts - Clean usage
import { streamText } from 'ai'
import { researchAgent } from '@/lib/agents/research-agent'

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    ...researchAgent,
    messages,
  })

  return result.toDataStreamResponse()
}

// app/api/research/route.ts - Same agent, different context
import { generateText } from 'ai'
import { researchAgent } from '@/lib/agents/research-agent'

export async function POST(req: Request) {
  const { query } = await req.json()

  const result = await generateText({
    ...researchAgent,
    prompt: query,
  })

  return Response.json({ result: result.text })
}

// Background job - Same agent again
import { researchAgent } from '@/lib/agents/research-agent'

export async function processResearchQueue(item: QueueItem) {
  const result = await generateText({
    ...researchAgent,
    prompt: item.query,
  })

  await saveResult(item.id, result.text)
}
```

**Agent with output schema:**

```typescript
import { z } from 'zod'

const analysisSchema = z.object({
  summary: z.string(),
  keyPoints: z.array(z.string()),
  sentiment: z.enum(['positive', 'negative', 'neutral']),
  confidence: z.number(),
})

export const analysisAgent = {
  model: openai('gpt-4-turbo'),
  system: 'You are an expert analyst...',
  tools: { /* ... */ },
  output: analysisSchema,  // Structured output
  maxSteps: 5,
}
```

Benefits of Agent abstraction:
- Single source of truth for agent behavior
- Consistent across all usage contexts
- Easy to test and modify
- Type-safe configuration
- Cleaner codebase
