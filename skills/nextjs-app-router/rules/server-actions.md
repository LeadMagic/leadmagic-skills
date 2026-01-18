---
title: Server Actions & React 19 Hooks
impact: CRITICAL
impactDescription: Correct patterns for mutations and form handling
tags: server-actions, useActionState, useOptimistic, useFormStatus, forms
---

## Server Actions & React 19 Hooks

Server Actions are async functions that run on the server, used for mutations and form handling.

### Basic Form Handling

```typescript
// app/posts/new/page.tsx
import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'

async function createPost(formData: FormData) {
  'use server'

  const title = formData.get('title') as string
  const content = formData.get('content') as string

  if (!title || !content) {
    return { error: 'Title and content required' }
  }

  await db.insert(posts).values({ title, content })

  revalidatePath('/posts')
  redirect('/posts')
}

export default function NewPostPage() {
  return (
    <form action={createPost}>
      <input name="title" placeholder="Title" required />
      <textarea name="content" placeholder="Content" required />
      <button type="submit">Create Post</button>
    </form>
  )
}
```

---

## useActionState (React 19)

Handle form state with pending status and error handling.

```typescript
// app/posts/new/page.tsx
'use client'

import { useActionState } from 'react'
import { createPost } from './actions'

export default function NewPostForm() {
  // IMPORTANT: Third element is `pending` boolean
  const [state, formAction, pending] = useActionState(createPost, null)

  return (
    <form action={formAction}>
      <input name="title" placeholder="Title" required />
      <textarea name="content" placeholder="Content" required />

      {state?.error && (
        <p className="text-red-500">{state.error}</p>
      )}

      <button type="submit" disabled={pending}>
        {pending ? 'Creating...' : 'Create Post'}
      </button>
    </form>
  )
}
```

```typescript
// app/posts/new/actions.ts
'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { z } from 'zod'

const schema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(1),
})

// CRITICAL: prevState MUST be first parameter when used with useActionState
export async function createPost(prevState: any, formData: FormData) {
  const validated = schema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
  })

  if (!validated.success) {
    return { error: validated.error.flatten().fieldErrors }
  }

  await db.insert(posts).values(validated.data)

  revalidatePath('/posts')
  redirect('/posts')
}
```

---

## useOptimistic (React 19)

Show instant UI feedback while mutation is pending.

```typescript
'use client'

import { useOptimistic } from 'react'
import { addTodo } from './actions'

export function TodoList({ todos }: { todos: Todo[] }) {
  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    todos,
    (state, newTodo: Todo) => [...state, newTodo]
  )

  async function handleSubmit(formData: FormData) {
    const title = formData.get('title') as string

    // Optimistically add to UI immediately
    addOptimisticTodo({ id: crypto.randomUUID(), title, completed: false })

    // Then actually create it
    await addTodo(formData)
  }

  return (
    <>
      <form action={handleSubmit}>
        <input name="title" required />
        <button type="submit">Add</button>
      </form>
      <ul>
        {optimisticTodos.map((todo) => (
          <li key={todo.id}>{todo.title}</li>
        ))}
      </ul>
    </>
  )
}
```

---

## useFormStatus (React 19)

Access form pending state from child components. **Must be used inside a child of `<form>`.**

```typescript
'use client'

import { useFormStatus } from 'react-dom'

// CRITICAL: Must be a child of <form>, not the same component
function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Submitting...' : 'Submit'}
    </button>
  )
}

export function Form({ action }: { action: (formData: FormData) => void }) {
  return (
    <form action={action}>
      <input name="email" type="email" required />
      <SubmitButton />
    </form>
  )
}
```

**Common mistake:**

```typescript
// ❌ WRONG - useFormStatus in same component as form
export function Form() {
  const { pending } = useFormStatus() // Won't work!
  return <form><button disabled={pending}>Submit</button></form>
}

// ✅ CORRECT - useFormStatus in child component
function SubmitButton() {
  const { pending } = useFormStatus()
  return <button disabled={pending}>Submit</button>
}

export function Form() {
  return (
    <form action={action}>
      <SubmitButton />
    </form>
  )
}
```
