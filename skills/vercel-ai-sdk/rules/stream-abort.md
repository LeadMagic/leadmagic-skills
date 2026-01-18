---
title: Implement Request Cancellation
impact: HIGH
impactDescription: Prevents wasted compute and API costs
tags: streaming, abort, cancellation, performance
---

## Implement Request Cancellation

Always implement abort functionality for streaming requests. Users navigating away or clicking "stop" should cancel the underlying API call to save resources and costs.

**Incorrect (no cancellation):**

```typescript
'use client'

import { useChat } from 'ai/react'

export function Chat() {
  const { messages, input, handleSubmit, isLoading } = useChat()

  return (
    <div>
      {messages.map(m => <Message key={m.id} message={m} />)}

      {isLoading && <div>Loading...</div>} {/* No way to stop */}

      <form onSubmit={handleSubmit}>
        <input value={input} />
        <button type="submit">Send</button>
      </form>
    </div>
  )
}
```

**Correct (with abort):**

```typescript
'use client'

import { useChat } from 'ai/react'

export function Chat() {
  const { messages, input, handleSubmit, isLoading, stop } = useChat({
    onError: (error) => {
      // AbortError is expected when user cancels
      if (error.name !== 'AbortError') {
        console.error('Chat error:', error)
      }
    },
  })

  return (
    <div>
      {messages.map(m => <Message key={m.id} message={m} />)}

      {isLoading && (
        <div className="flex items-center gap-2">
          <span>Thinking...</span>
          <button
            onClick={stop}
            className="text-sm text-red-500 hover:underline"
          >
            Stop generating
          </button>
        </div>
      )}

      <form onSubmit={handleSubmit}>
        <input value={input} />
        <button type="submit" disabled={isLoading}>
          {isLoading ? 'Stop' : 'Send'}
        </button>
      </form>
    </div>
  )
}
```

**Manual Abort with streamText:**

```typescript
import { openai } from '@ai-sdk/openai'
import { streamText } from 'ai'

// Create AbortController for manual cancellation
export async function POST(req: Request) {
  const { messages } = await req.json()

  // The request signal is automatically used for cancellation
  const result = streamText({
    model: openai('gpt-4-turbo'),
    messages,
    abortSignal: req.signal, // Pass request signal for automatic abort on disconnect
  })

  return result.toDataStreamResponse()
}

// Client-side manual abort
async function streamWithAbort() {
  const controller = new AbortController()

  // Cancel after 30 seconds
  const timeout = setTimeout(() => controller.abort(), 30000)

  try {
    const response = await fetch('/api/chat', {
      method: 'POST',
      body: JSON.stringify({ messages }),
      signal: controller.signal,
    })

    // Process stream...
    clearTimeout(timeout)
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Request was cancelled')
    } else {
      throw error
    }
  }
}
```

**Abort on Navigation:**

```typescript
'use client'

import { useEffect } from 'react'
import { useChat } from 'ai/react'
import { useRouter } from 'next/navigation'

export function Chat() {
  const { stop, isLoading } = useChat()
  const router = useRouter()

  // Abort when component unmounts (navigation)
  useEffect(() => {
    return () => {
      if (isLoading) {
        stop()
      }
    }
  }, [isLoading, stop])

  // Warn before navigation during generation
  useEffect(() => {
    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      if (isLoading) {
        e.preventDefault()
        e.returnValue = ''
      }
    }

    window.addEventListener('beforeunload', handleBeforeUnload)
    return () => window.removeEventListener('beforeunload', handleBeforeUnload)
  }, [isLoading])

  return <div>...</div>
}
```

**useCompletion with Abort:**

```typescript
'use client'

import { useCompletion } from 'ai/react'

export function Autocomplete() {
  const { completion, input, handleInputChange, handleSubmit, stop, isLoading } = useCompletion({
    api: '/api/completion',
  })

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <textarea
          value={input}
          onChange={handleInputChange}
          placeholder="Start typing..."
        />
        <div className="flex gap-2">
          <button type="submit" disabled={isLoading}>
            Generate
          </button>
          {isLoading && (
            <button type="button" onClick={stop}>
              Cancel
            </button>
          )}
        </div>
      </form>

      {completion && (
        <div className="mt-4 p-4 bg-gray-100 rounded">
          {completion}
        </div>
      )}
    </div>
  )
}
```

**Server-Side Timeout:**

```typescript
import { openai } from '@ai-sdk/openai'
import { streamText } from 'ai'

export async function POST(req: Request) {
  const { messages } = await req.json()

  // Create timeout abort
  const controller = new AbortController()
  const timeout = setTimeout(() => {
    controller.abort()
  }, 60000) // 60 second max

  try {
    const result = streamText({
      model: openai('gpt-4-turbo'),
      messages,
      abortSignal: controller.signal,
      onFinish: () => clearTimeout(timeout),
    })

    return result.toDataStreamResponse()
  } catch (error) {
    clearTimeout(timeout)

    if (error.name === 'AbortError') {
      return new Response('Request timed out', { status: 408 })
    }
    throw error
  }
}
```
