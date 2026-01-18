---
title: Use AI Elements for Chat Interfaces
impact: HIGH
impactDescription: Production-ready AI UI components
tags: ai-elements, chat, components, vercel
---

## Use AI Elements for Chat Interfaces

AI Elements is Vercel's component library built on shadcn/ui, specifically designed for AI interfaces. Use these instead of building chat UIs from scratch.

**Installation:**

```bash
# Prerequisites
# - Node.js 18+
# - Next.js with AI SDK installed
# - shadcn/ui initialized
# - Tailwind in CSS Variables mode

# Install all components
npx ai-elements@latest

# Or install specific components
npx ai-elements@latest add conversation message prompt-input
npx ai-elements@latest add code-block reasoning sources tools
```

**Available Components (20+):**

| Component | Purpose |
|-----------|---------|
| `Conversation` | Chat container with auto-scroll |
| `ConversationContent` | Message list wrapper |
| `Message` | Individual message bubble |
| `MessageContent` | Message text/parts |
| `MessageResponse` | AI response with markdown |
| `PromptInput` | User input field |
| `PromptInputSubmit` | Submit button |
| `CodeBlock` | Syntax-highlighted code |
| `Reasoning` | AI thinking/reasoning display |
| `Sources` | Citation/source references |
| `Tools` | Tool invocation display |
| `ModelSelector` | Model selection dropdown |
| `MessageAttachments` | File attachments |
| `Suggestion` | Quick reply suggestions |

**Basic Chat Implementation:**

```typescript
'use client'

import { useChat } from 'ai/react'
import {
  Conversation,
  ConversationContent,
  Message,
  MessageContent,
  PromptInput,
  PromptInputSubmit,
} from '@/components/ui/ai'

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat()

  return (
    <div className="flex flex-col h-screen">
      <Conversation className="flex-1">
        <ConversationContent>
          {messages.map((message) => (
            <Message key={message.id} message={message}>
              <MessageContent message={message} />
            </Message>
          ))}
        </ConversationContent>
      </Conversation>

      <form onSubmit={handleSubmit} className="p-4 border-t">
        <div className="flex gap-2">
          <PromptInput
            value={input}
            onChange={handleInputChange}
            placeholder="Type a message..."
            disabled={isLoading}
          />
          <PromptInputSubmit disabled={isLoading} />
        </div>
      </form>
    </div>
  )
}
```

**With Tool Calls and Reasoning:**

```typescript
'use client'

import { useChat } from 'ai/react'
import {
  Conversation,
  Message,
  MessageContent,
  Reasoning,
  Tools,
  CodeBlock,
} from '@/components/ui/ai'

export function AdvancedChat() {
  const { messages, ... } = useChat()

  return (
    <Conversation>
      {messages.map((message) => (
        <Message key={message.id} message={message}>
          {/* Show reasoning if available */}
          {message.reasoning && (
            <Reasoning>{message.reasoning}</Reasoning>
          )}

          {/* Show tool invocations */}
          {message.toolInvocations?.map((tool, i) => (
            <Tools key={i} toolInvocation={tool} />
          ))}

          {/* Message content with code highlighting */}
          <MessageContent message={message}>
            {({ type, content }) => {
              if (type === 'code') {
                return <CodeBlock language={content.language}>{content.code}</CodeBlock>
              }
              return content
            }}
          </MessageContent>
        </Message>
      ))}
    </Conversation>
  )
}
```

**With Sources/Citations:**

```typescript
import { Sources, SourceItem } from '@/components/ui/ai'

function MessageWithSources({ message }) {
  return (
    <Message message={message}>
      <MessageContent message={message} />

      {message.sources && (
        <Sources>
          {message.sources.map((source, i) => (
            <SourceItem
              key={i}
              title={source.title}
              url={source.url}
              snippet={source.snippet}
            />
          ))}
        </Sources>
      )}
    </Message>
  )
}
```

**Model Selection:**

```typescript
import { ModelSelector } from '@/components/ui/ai'

function ChatSettings() {
  const [model, setModel] = useState('gpt-4-turbo')

  return (
    <ModelSelector
      value={model}
      onValueChange={setModel}
      models={[
        { id: 'gpt-4-turbo', name: 'GPT-4 Turbo', provider: 'openai' },
        { id: 'claude-3-opus', name: 'Claude 3 Opus', provider: 'anthropic' },
        { id: 'gemini-pro', name: 'Gemini Pro', provider: 'google' },
      ]}
    />
  )
}
```

**Alternative: Install via shadcn Registry:**

```bash
# Using shadcn CLI with AI Elements registry
npx shadcn@latest add "https://registry.ai-sdk.dev/conversation.json"
npx shadcn@latest add "https://registry.ai-sdk.dev/message.json"
```

**Why AI Elements over custom:**

- ✅ Handles streaming correctly
- ✅ Proper auto-scroll behavior
- ✅ Markdown rendering with syntax highlighting
- ✅ Tool call visualization
- ✅ Accessibility built-in
- ✅ Dark mode support
- ✅ Consistent with shadcn/ui patterns
- ✅ Regular updates from Vercel
