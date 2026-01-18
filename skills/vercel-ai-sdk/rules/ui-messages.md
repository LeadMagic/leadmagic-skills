---
title: Handle Message Parts Correctly
impact: HIGH
impactDescription: Proper rendering of tool calls and multi-part messages
tags: ui, messages, streaming, tool-calls
---

## Handle Message Parts Correctly

Messages from AI SDK can contain multiple parts: text, tool invocations, tool results, and reasoning. Always check `message.parts` instead of just `message.content`.

**Incorrect (only handling text content):**

```typescript
'use client'

import { useChat } from 'ai/react'

export function Chat() {
  const { messages } = useChat()

  return (
    <div>
      {messages.map((message) => (
        <div key={message.id}>
          {/* This misses tool calls and other parts! */}
          <p>{message.content}</p>
        </div>
      ))}
    </div>
  )
}
```

**Correct (handling all message parts):**

```typescript
'use client'

import { useChat, type Message } from 'ai/react'
import { Fragment } from 'react'

export function Chat() {
  const { messages } = useChat()

  return (
    <div className="space-y-4">
      {messages.map((message) => (
        <MessageBubble key={message.id} message={message} />
      ))}
    </div>
  )
}

function MessageBubble({ message }: { message: Message }) {
  const isUser = message.role === 'user'

  return (
    <div className={isUser ? 'text-right' : 'text-left'}>
      <div className={`inline-block p-4 rounded-lg ${
        isUser ? 'bg-blue-500 text-white' : 'bg-gray-100'
      }`}>
        {/* Handle parts if available, fallback to content */}
        {message.parts ? (
          message.parts.map((part, index) => (
            <MessagePart key={index} part={part} />
          ))
        ) : (
          <p className="whitespace-pre-wrap">{message.content}</p>
        )}
      </div>
    </div>
  )
}

function MessagePart({ part }: { part: any }) {
  switch (part.type) {
    case 'text':
      return <p className="whitespace-pre-wrap">{part.text}</p>

    case 'tool-invocation':
      return (
        <div className="my-2 p-3 bg-yellow-50 rounded border border-yellow-200">
          <div className="flex items-center gap-2 text-sm text-yellow-800">
            <span>🔧</span>
            <span className="font-medium">{part.toolName}</span>
            {part.state === 'pending' && (
              <span className="animate-pulse">Running...</span>
            )}
          </div>
          {part.args && (
            <pre className="mt-2 text-xs overflow-auto">
              {JSON.stringify(part.args, null, 2)}
            </pre>
          )}
        </div>
      )

    case 'tool-result':
      return (
        <div className="my-2 p-3 bg-green-50 rounded border border-green-200">
          <div className="text-sm text-green-800 font-medium">
            ✓ Result from {part.toolName}
          </div>
          <pre className="mt-2 text-xs overflow-auto">
            {JSON.stringify(part.result, null, 2)}
          </pre>
        </div>
      )

    case 'reasoning':
      return (
        <details className="my-2">
          <summary className="text-sm text-gray-500 cursor-pointer">
            💭 Reasoning
          </summary>
          <p className="mt-2 text-sm text-gray-600 italic">
            {part.reasoning}
          </p>
        </details>
      )

    default:
      return null
  }
}
```

**With markdown rendering:**

```typescript
import ReactMarkdown from 'react-markdown'
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter'

function MessagePart({ part }: { part: any }) {
  if (part.type === 'text') {
    return (
      <ReactMarkdown
        components={{
          code({ node, inline, className, children, ...props }) {
            const match = /language-(\w+)/.exec(className || '')
            return !inline && match ? (
              <SyntaxHighlighter language={match[1]} PreTag="div" {...props}>
                {String(children).replace(/\n$/, '')}
              </SyntaxHighlighter>
            ) : (
              <code className={className} {...props}>
                {children}
              </code>
            )
          },
        }}
      >
        {part.text}
      </ReactMarkdown>
    )
  }
  // ... handle other part types
}
```

Key part types to handle:
- `text` - Regular text content
- `tool-invocation` - Tool being called (with args, state)
- `tool-result` - Result from a tool execution
- `reasoning` - Model's reasoning/thinking (if exposed)
