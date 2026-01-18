---
title: Use useChat Hook for Chat Interfaces
impact: CRITICAL
impactDescription: Proper streaming and state management for chat UIs
tags: streaming, react, chat, hooks
---

## Use useChat Hook for Chat Interfaces

The `useChat` hook from `ai/react` provides built-in state management for messages, input handling, loading states, and streaming. Using it correctly ensures a smooth chat experience.

**Incorrect (manual state management):**

```typescript
'use client'

import { useState } from 'react'

export function Chat() {
  const [messages, setMessages] = useState([])
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)

    // Manual fetch - loses streaming benefits
    const response = await fetch('/api/chat', {
      method: 'POST',
      body: JSON.stringify({ messages: [...messages, { role: 'user', content: input }] }),
    })

    const data = await response.json()
    setMessages([...messages, { role: 'user', content: input }, data])
    setLoading(false)
    setInput('')
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={input} onChange={(e) => setInput(e.target.value)} />
    </form>
  )
}
```

**Correct (using useChat):**

```typescript
'use client'

import { useChat } from 'ai/react'

export function Chat() {
  const {
    messages,
    input,
    handleInputChange,
    handleSubmit,
    isLoading,
    error,
    reload,
    stop,
  } = useChat({
    api: '/api/chat',
    maxSteps: 5, // Enable multi-step tool calls
    onError: (error) => {
      console.error('Chat error:', error)
    },
    onFinish: (message) => {
      console.log('Message complete:', message)
    },
  })

  return (
    <div>
      {messages.map((m) => (
        <div key={m.id} className={m.role === 'user' ? 'text-right' : 'text-left'}>
          {m.content}
        </div>
      ))}

      {isLoading && <div>Thinking...</div>}
      {error && <div className="text-red-500">{error.message}</div>}

      <form onSubmit={handleSubmit}>
        <input
          value={input}
          onChange={handleInputChange}
          disabled={isLoading}
        />
        {isLoading && <button type="button" onClick={stop}>Stop</button>}
      </form>
    </div>
  )
}
```

The `useChat` hook handles:
- Message state with proper IDs
- Input state and handlers
- Streaming response updates
- Loading and error states
- Tool call execution
- Abort/stop functionality
- Retry/reload capability
