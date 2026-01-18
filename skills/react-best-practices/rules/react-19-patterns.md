---
title: React 19 Patterns
impact: CRITICAL
impactDescription: Use React 19 features correctly for optimal performance
tags: react-19, use, useActionState, useOptimistic, forwardRef, ref
---

## React 19 Patterns

Essential patterns for React 19 features.

---

### 1. use() Hook for Promises

Read promises directly in components with Suspense.

```typescript
import { use, Suspense } from 'react'

// Create promise OUTSIDE the component (or in parent)
// Never create promises inside render
function Comments({ commentsPromise }: { commentsPromise: Promise<Comment[]> }) {
  const comments = use(commentsPromise) // Suspends until resolved
  return (
    <ul>
      {comments.map((c) => <li key={c.id}>{c.text}</li>)}
    </ul>
  )
}

// Parent provides the promise and Suspense boundary
function Page() {
  const commentsPromise = fetchComments() // Created in parent

  return (
    <Suspense fallback={<div>Loading comments...</div>}>
      <Comments commentsPromise={commentsPromise} />
    </Suspense>
  )
}
```

### 2. use() for Conditional Context

Read context conditionally (impossible with useContext).

```typescript
import { use } from 'react'

function StatusMessage({ isLoggedIn }: { isLoggedIn: boolean }) {
  // Can read context conditionally!
  if (isLoggedIn) {
    const user = use(UserContext)
    return <p>Welcome, {user.name}</p>
  }
  return <p>Please log in</p>
}
```

---

### 3. ref as Prop (No forwardRef)

React 19 allows `ref` as a regular prop.

```typescript
// ❌ OLD - forwardRef (deprecated in future)
const Input = forwardRef<HTMLInputElement, InputProps>((props, ref) => {
  return <input ref={ref} {...props} />
})

// ✅ NEW - ref as prop
function Input({ placeholder, ref }: {
  placeholder?: string
  ref?: React.Ref<HTMLInputElement>
}) {
  return <input placeholder={placeholder} ref={ref} />
}

// Usage
function Form() {
  const inputRef = useRef<HTMLInputElement>(null)
  return <Input ref={inputRef} placeholder="Enter name" />
}
```

---

### 4. Ref Cleanup Functions

Return a cleanup function from ref callbacks.

```typescript
// ❌ OLD - refs called with null on unmount
<input ref={(el) => {
  if (el) {
    el.focus()
  }
  // No cleanup
}} />

// ✅ NEW - return cleanup function
<input ref={(el) => {
  if (!el) return

  const observer = new IntersectionObserver(/* ... */)
  observer.observe(el)

  // Return cleanup (called on unmount)
  return () => {
    observer.disconnect()
  }
}} />
```

---

### 5. useActionState

Handle form actions with state and pending.

```typescript
'use client'

import { useActionState } from 'react'

// Action receives (prevState, formData)
async function submitForm(prevState: any, formData: FormData) {
  const email = formData.get('email')

  try {
    await subscribe(email)
    return { success: true, message: 'Subscribed!' }
  } catch (error) {
    return { success: false, message: 'Failed to subscribe' }
  }
}

function NewsletterForm() {
  const [state, formAction, pending] = useActionState(submitForm, null)

  return (
    <form action={formAction}>
      <input name="email" type="email" disabled={pending} required />
      <button type="submit" disabled={pending}>
        {pending ? 'Subscribing...' : 'Subscribe'}
      </button>
      {state?.message && (
        <p className={state.success ? 'text-green-500' : 'text-red-500'}>
          {state.message}
        </p>
      )}
    </form>
  )
}
```

---

### 6. useOptimistic

Instant UI updates while mutations are in flight.

```typescript
'use client'

import { useOptimistic, useTransition } from 'react'

function LikeButton({ initialLikes, postId }: { initialLikes: number; postId: string }) {
  const [isPending, startTransition] = useTransition()
  const [optimisticLikes, addOptimisticLike] = useOptimistic(
    initialLikes,
    (current, increment: number) => current + increment
  )

  async function handleLike() {
    startTransition(async () => {
      addOptimisticLike(1) // Immediately show +1
      await likePost(postId) // Then actually update
    })
  }

  return (
    <button onClick={handleLike} disabled={isPending}>
      {optimisticLikes} likes
    </button>
  )
}
```

---

### 7. useFormStatus

Access form state from child components.

```typescript
'use client'

import { useFormStatus } from 'react-dom'

// MUST be a child of <form>, not the form component itself
function SubmitButton({ children }: { children: React.ReactNode }) {
  const { pending, data, method, action } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Submitting...' : children}
    </button>
  )
}

// Usage - SubmitButton INSIDE form
function ContactForm({ action }: { action: (fd: FormData) => Promise<void> }) {
  return (
    <form action={action}>
      <input name="message" required />
      <SubmitButton>Send Message</SubmitButton>
    </form>
  )
}
```

---

### 8. React Compiler (Auto-Memoization)

With React Compiler, you don't need useMemo/useCallback.

```typescript
// next.config.ts - enable React Compiler
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactCompiler: true,
}

export default nextConfig
```

```typescript
// ❌ OLD - manual memoization
function ProductList({ products, onSelect }) {
  const sortedProducts = useMemo(
    () => products.sort((a, b) => a.price - b.price),
    [products]
  )

  const handleSelect = useCallback(
    (id) => onSelect(id),
    [onSelect]
  )

  return /* ... */
}

// ✅ NEW with React Compiler - write naturally
function ProductList({ products, onSelect }) {
  // Compiler automatically memoizes as needed
  const sortedProducts = products.sort((a, b) => a.price - b.price)
  const handleSelect = (id) => onSelect(id)

  return /* ... */
}
```

---

## Migration Checklist

- [ ] Remove `forwardRef` - use `ref` as prop
- [ ] Replace ref `null` checks with cleanup returns
- [ ] Use `use()` for promises instead of useEffect + useState
- [ ] Use `useActionState` instead of manual form state
- [ ] Add `useOptimistic` for instant feedback
- [ ] Enable React Compiler, remove useMemo/useCallback
- [ ] Update Next.js 16: `middleware.ts` → `proxy.ts`
