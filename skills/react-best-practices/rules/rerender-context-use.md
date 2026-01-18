---
title: Use React 19's use() for Context
impact: HIGH
impactDescription: Flexible context consumption with conditional calling
tags: react-19, context, use-hook, performance
---

## Use React 19's use() for Context

React 19 introduces the `use` function which can consume context (and promises) with more flexibility than `useContext`. Unlike hooks, `use` can be called conditionally.

**Incorrect (useContext limitations):**

```typescript
// useContext must be called unconditionally at top level
function ConditionalFeature({ enabled }: { enabled: boolean }) {
  // This runs even when enabled is false
  const theme = useContext(ThemeContext)
  const user = useContext(UserContext)

  if (!enabled) {
    return null
  }

  return <ThemedComponent theme={theme} user={user} />
}

// Can't use context in loops
function ItemList({ items }: { items: Item[] }) {
  // Must call once at top, pass down to each item
  const config = useContext(ConfigContext)

  return items.map(item => (
    <Item key={item.id} item={item} config={config} />
  ))
}
```

**Correct (React 19 use):**

```typescript
import { use } from 'react'

// Can call use() conditionally
function ConditionalFeature({ enabled }: { enabled: boolean }) {
  if (!enabled) {
    return null
  }

  // Only reads context when actually needed
  const theme = use(ThemeContext)
  const user = use(UserContext)

  return <ThemedComponent theme={theme} user={user} />
}

// Can use in early returns
function ProtectedContent() {
  const auth = use(AuthContext)

  if (!auth.isAuthenticated) {
    return <LoginPrompt />
  }

  // Only read user context if authenticated
  const user = use(UserContext)
  return <UserDashboard user={user} />
}
```

**use() with Promises:**

```typescript
import { use, Suspense } from 'react'

// use() can unwrap promises inside render
function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise) // Suspends until resolved
  return <Profile user={user} />
}

// Parent provides promise and Suspense boundary
function ProfilePage({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId) // Start fetch immediately

  return (
    <Suspense fallback={<ProfileSkeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}

// Multiple components can share the same promise
function ProfileWithStats({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId)

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
      <UserStats userPromise={userPromise} /> {/* Reuses same promise */}
    </Suspense>
  )
}
```

**Migration from useContext:**

```typescript
// Before (React 18)
import { useContext } from 'react'

function Component() {
  const theme = useContext(ThemeContext)
  return <div style={{ color: theme.primary }}>...</div>
}

// After (React 19) - Simple replacement works
import { use } from 'react'

function Component() {
  const theme = use(ThemeContext)
  return <div style={{ color: theme.primary }}>...</div>
}

// After (React 19) - Now with conditional benefits
function Component({ showThemed }: { showThemed: boolean }) {
  if (!showThemed) {
    return <PlainContent />
  }

  const theme = use(ThemeContext) // Only read when needed
  return <ThemedContent theme={theme} />
}
```

**Key Differences:**

| Feature | useContext | use |
|---------|------------|-----|
| Conditional calls | ❌ No | ✅ Yes |
| Inside loops | ❌ No | ✅ Yes |
| Early returns before | ❌ No | ✅ Yes |
| Unwrap promises | ❌ No | ✅ Yes |
| Works with context | ✅ Yes | ✅ Yes |

**Note:** Legacy context APIs (`contextTypes`, `getChildContext`) are removed in React 19. Migrate to `createContext` if still using them.
