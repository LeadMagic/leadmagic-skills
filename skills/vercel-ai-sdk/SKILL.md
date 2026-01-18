---
name: vercel-ai-sdk
description: Best practices for building AI applications with Vercel AI SDK 5/6. Use when implementing chat interfaces, streaming responses, tool calling, agents, structured outputs, or AI-powered features. Triggers on "AI SDK", "useChat", "streamText", "generateText", "generateObject", "AI chat", "LLM integration", "tool calling".
license: MIT
metadata:
  author: leadmagic
  version: "2.0.0"
---

# Vercel AI SDK Best Practices

Comprehensive guide for building AI-powered applications with Vercel AI SDK 5/6. Contains 25+ rules across 7 categories.

## What's New in AI SDK v5

- **`toolCallStreaming` enabled by default** - Partial tool calls stream in real-time
- **`toUIMessageStreamResponse()`** - New response helper for UI message streams
- **Multi-step agent patterns** - Chain multiple `streamText` calls with `writer.merge`
- **`@ai-sdk/react`** - New package structure for React hooks

## When to Apply

Reference these guidelines when:
- Building chat interfaces with streaming
- Implementing AI agents with tool calling
- Creating structured AI outputs
- Integrating multiple LLM providers
- Building AI-powered features in React/Next.js

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Streaming & Chat | CRITICAL | `stream-` |
| 2 | Tool Calling | CRITICAL | `tools-` |
| 3 | Agents | HIGH | `agent-` |
| 4 | Structured Output | HIGH | `output-` |
| 5 | Provider Integration | MEDIUM | `provider-` |
| 6 | UI Patterns | MEDIUM | `ui-` |
| 7 | Voice & Audio | MEDIUM | `voice-` |

## Quick Reference

### 1. Streaming & Chat (CRITICAL)

- `stream-useChat` - Use useChat hook for chat interfaces
- `stream-server-client` - Match server/client maxSteps config
- `stream-error-handling` - Handle streaming errors gracefully
- `stream-abort` - Implement request cancellation with stop()

### 2. Tool Calling (CRITICAL)

- `tools-schema` - Define tools with Zod schemas
- `tools-approval` - Use needsApproval for dangerous operations
- `tools-execution` - Handle tool execution properly
- `tools-validation` - Validate tool inputs/outputs

### 3. Agents (HIGH)

- `agent-abstraction` - Use Agent interface for reusable agents
- `agent-tool-loop` - Implement tool loops correctly
- `agent-instructions` - Define clear agent instructions
- `agent-context` - Manage agent context efficiently

### 4. Structured Output (HIGH)

- `output-schema` - Use schema for structured responses
- `output-zod` - Define output types with Zod
- `output-validation` - Validate AI outputs

### 5. Provider Integration (MEDIUM)

- `provider-selection` - Choose appropriate providers
- `provider-fallback` - Implement provider fallbacks
- `provider-config` - Configure providers correctly
- `provider-edge` - Use Edge runtime for AI routes

### 6. UI Patterns (MEDIUM)

- `ui-streaming` - Render streaming content properly
- `ui-loading` - Show loading states
- `ui-messages` - Handle message parts correctly

### 7. Voice & Audio (MEDIUM)

- `voice-elements` - Use Voice Elements for speech interfaces
- `voice-speech-input` - Implement speech recognition
- `voice-transcription` - Display live transcriptions

## Essential Patterns

### Basic Chat with useChat

```typescript
// app/page.tsx (Client Component)
'use client'

import { useChat } from 'ai/react'

export default function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading, error } = useChat({
    api: '/api/chat',
    maxSteps: 5, // Must match server config!
    onError: (error) => {
      console.error('Chat error:', error)
    },
  })

  return (
    <div className="flex flex-col h-screen">
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((message) => (
          <div key={message.id} className={message.role === 'user' ? 'text-right' : 'text-left'}>
            <div className="inline-block p-3 rounded-lg">
              {/* Handle different message parts */}
              {message.parts?.map((part, i) => {
                if (part.type === 'text') {
                  return <p key={i}>{part.text}</p>
                }
                if (part.type === 'tool-invocation') {
                  return (
                    <div key={i} className="text-sm text-gray-500">
                      🔧 {part.toolName}: {JSON.stringify(part.args)}
                    </div>
                  )
                }
                return null
              }) ?? <p>{message.content}</p>}
            </div>
          </div>
        ))}

        {isLoading && <div className="animate-pulse">Thinking...</div>}
        {error && <div className="text-red-500">Error: {error.message}</div>}
      </div>

      <form onSubmit={handleSubmit} className="p-4 border-t">
        <input
          value={input}
          onChange={handleInputChange}
          placeholder="Type a message..."
          className="w-full p-2 border rounded"
          disabled={isLoading}
        />
      </form>
    </div>
  )
}
```

### Server Route with Streaming

```typescript
// app/api/chat/route.ts
import { openai } from '@ai-sdk/openai'
import { streamText, tool } from 'ai'
import { z } from 'zod'

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    maxSteps: 5, // Must match client config!
    tools: {
      getWeather: tool({
        description: 'Get the current weather for a location',
        parameters: z.object({
          location: z.string().describe('City name'),
        }),
        execute: async ({ location }) => {
          // Fetch weather data
          return { temperature: 72, condition: 'sunny', location }
        },
      }),
      searchDatabase: tool({
        description: 'Search the database for information',
        parameters: z.object({
          query: z.string(),
          limit: z.number().default(10),
        }),
        // Mark dangerous operations for approval
        needsApproval: false,
        execute: async ({ query, limit }) => {
          // Search logic
          return { results: [], query, limit }
        },
      }),
    },
    onFinish: ({ usage }) => {
      console.log('Token usage:', usage)
    },
  })

  return result.toDataStreamResponse()
}
```

### Structured Output with Schema

```typescript
import { openai } from '@ai-sdk/openai'
import { generateObject } from 'ai'
import { z } from 'zod'

// Define output schema
const recipeSchema = z.object({
  name: z.string(),
  ingredients: z.array(z.object({
    name: z.string(),
    amount: z.string(),
    unit: z.string(),
  })),
  steps: z.array(z.string()),
  prepTime: z.number().describe('Preparation time in minutes'),
  cookTime: z.number().describe('Cooking time in minutes'),
  servings: z.number(),
})

type Recipe = z.infer<typeof recipeSchema>

export async function generateRecipe(dish: string): Promise<Recipe> {
  const { object } = await generateObject({
    model: openai('gpt-4-turbo'),
    schema: recipeSchema,
    prompt: `Generate a detailed recipe for: ${dish}`,
  })

  return object
}
```

### Agent with Tool Loop

```typescript
import { openai } from '@ai-sdk/openai'
import { generateText, tool } from 'ai'
import { z } from 'zod'

// Define reusable agent
const researchAgent = {
  model: openai('gpt-4-turbo'),
  system: `You are a research assistant. Use the available tools to find
    information and provide comprehensive answers. Always cite your sources.`,
  tools: {
    webSearch: tool({
      description: 'Search the web for information',
      parameters: z.object({
        query: z.string(),
      }),
      execute: async ({ query }) => {
        // Implement web search
        return { results: [] }
      },
    }),
    readUrl: tool({
      description: 'Read content from a URL',
      parameters: z.object({
        url: z.string().url(),
      }),
      execute: async ({ url }) => {
        // Fetch and parse URL content
        return { content: '', url }
      },
    }),
  },
  maxSteps: 10,
}

export async function research(question: string) {
  const result = await generateText({
    ...researchAgent,
    prompt: question,
  })

  return {
    answer: result.text,
    toolCalls: result.toolCalls,
    usage: result.usage,
  }
}
```

### Multi-Provider Setup

```typescript
import { openai } from '@ai-sdk/openai'
import { anthropic } from '@ai-sdk/anthropic'
import { google } from '@ai-sdk/google'
import { generateText } from 'ai'

// Provider configuration
const providers = {
  openai: openai('gpt-4-turbo'),
  claude: anthropic('claude-3-opus-20240229'),
  gemini: google('gemini-pro'),
}

// With fallback
async function generateWithFallback(prompt: string) {
  const providerOrder = ['openai', 'claude', 'gemini'] as const

  for (const providerName of providerOrder) {
    try {
      const result = await generateText({
        model: providers[providerName],
        prompt,
      })
      return { result, provider: providerName }
    } catch (error) {
      console.warn(`${providerName} failed, trying next...`)
      continue
    }
  }

  throw new Error('All providers failed')
}
```

### Tool with Human Approval

```typescript
import { tool } from 'ai'
import { z } from 'zod'

// Dangerous tool requiring approval
const deleteFilesTool = tool({
  description: 'Delete files from the system',
  parameters: z.object({
    paths: z.array(z.string()).describe('File paths to delete'),
    force: z.boolean().default(false),
  }),
  // Require human approval before execution
  needsApproval: true,
  execute: async ({ paths, force }) => {
    // This only runs after approval
    const deleted: string[] = []
    for (const path of paths) {
      await deleteFile(path, { force })
      deleted.push(path)
    }
    return { deleted, count: deleted.length }
  },
})

// Safe tool - no approval needed
const readFileTool = tool({
  description: 'Read a file from the system',
  parameters: z.object({
    path: z.string(),
  }),
  needsApproval: false,
  execute: async ({ path }) => {
    const content = await readFile(path)
    return { content, path }
  },
})
```

### Streaming with Tool Results

```typescript
'use client'

import { useChat } from 'ai/react'
import { useState } from 'react'

export function ChatWithTools() {
  const [pendingApproval, setPendingApproval] = useState<any>(null)

  const { messages, input, handleInputChange, handleSubmit, addToolResult } = useChat({
    api: '/api/chat',
    maxSteps: 5,
    onToolCall: async ({ toolCall }) => {
      // Handle tools that need approval
      if (toolCall.toolName === 'deleteFiles') {
        setPendingApproval(toolCall)
        return // Don't execute yet
      }
    },
  })

  const handleApprove = async () => {
    if (pendingApproval) {
      // Execute the tool and add result
      const result = await executeToolOnServer(pendingApproval)
      addToolResult({
        toolCallId: pendingApproval.toolCallId,
        result,
      })
      setPendingApproval(null)
    }
  }

  return (
    <div>
      {/* Messages */}
      {messages.map((m) => (
        <div key={m.id}>{m.content}</div>
      ))}

      {/* Approval dialog */}
      {pendingApproval && (
        <div className="p-4 bg-yellow-100 rounded">
          <p>Approve action: {pendingApproval.toolName}?</p>
          <pre>{JSON.stringify(pendingApproval.args, null, 2)}</pre>
          <button onClick={handleApprove}>Approve</button>
          <button onClick={() => setPendingApproval(null)}>Reject</button>
        </div>
      )}

      {/* Input */}
      <form onSubmit={handleSubmit}>
        <input value={input} onChange={handleInputChange} />
      </form>
    </div>
  )
}
```

## Common Mistakes

| Mistake | Problem | Solution |
|---------|---------|----------|
| Mismatched maxSteps | Tools silently fail | Match client and server maxSteps |
| No error handling | Crashes on API errors | Use onError callback |
| Raw content parsing | Breaks with tool calls | Use message.parts |
| No loading state | Poor UX | Use isLoading from useChat |
| No abort handling | Wasted resources | Implement cancel functionality |

## Installation

```bash
npm install ai @ai-sdk/openai @ai-sdk/anthropic zod
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
