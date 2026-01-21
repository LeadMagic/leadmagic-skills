---
name: zustand
description: Zustand state management for React. Use when managing global state, creating stores, or replacing Context/Redux. Triggers on "state management", "zustand", "store", "global state", "create store".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Zustand - State Management

Lightweight state management with minimal boilerplate.

## Why Zustand

| Feature | Zustand | Redux | Context |
|---------|---------|-------|---------|
| Bundle size | ~1KB | ~7KB | 0 (built-in) |
| Boilerplate | Minimal | High | Medium |
| Re-renders | Optimized | Optimized | All consumers |
| DevTools | Yes | Yes | No |
| Persistence | Plugin | Plugin | Manual |

## Installation

```bash
npm install zustand
```

---

## Basic Store

```typescript
// stores/counter.ts
import { create } from 'zustand'

interface CounterStore {
  count: number
  increment: () => void
  decrement: () => void
  reset: () => void
}

export const useCounterStore = create<CounterStore>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}))
```

```tsx
// Usage in component
'use client'

import { useCounterStore } from '@/stores/counter'

export function Counter() {
  const { count, increment, decrement } = useCounterStore()

  return (
    <div>
      <span>{count}</span>
      <button onClick={increment}>+</button>
      <button onClick={decrement}>-</button>
    </div>
  )
}
```

---

## Selecting State (Performance)

```tsx
// ❌ Bad: Re-renders on ANY store change
const { count, user, settings } = useStore()

// ✅ Good: Only re-renders when count changes
const count = useStore((state) => state.count)

// ✅ Good: Multiple selectors with shallow equality
import { useShallow } from 'zustand/react/shallow'

const { count, user } = useStore(
  useShallow((state) => ({ count: state.count, user: state.user }))
)
```

---

## Async Actions

```typescript
// stores/user.ts
import { create } from 'zustand'

interface UserStore {
  user: User | null
  isLoading: boolean
  error: string | null
  fetchUser: (id: string) => Promise<void>
  updateUser: (data: Partial<User>) => Promise<void>
}

export const useUserStore = create<UserStore>((set, get) => ({
  user: null,
  isLoading: false,
  error: null,

  fetchUser: async (id) => {
    set({ isLoading: true, error: null })
    try {
      const response = await fetch(`/api/users/${id}`)
      const user = await response.json()
      set({ user, isLoading: false })
    } catch (error) {
      set({ error: 'Failed to fetch user', isLoading: false })
    }
  },

  updateUser: async (data) => {
    const { user } = get()
    if (!user) return

    set({ isLoading: true })
    try {
      const response = await fetch(`/api/users/${user.id}`, {
        method: 'PATCH',
        body: JSON.stringify(data),
      })
      const updated = await response.json()
      set({ user: updated, isLoading: false })
    } catch (error) {
      set({ error: 'Failed to update user', isLoading: false })
    }
  },
}))
```

---

## Persist Middleware

```typescript
import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'

interface SettingsStore {
  theme: 'light' | 'dark' | 'system'
  sidebarOpen: boolean
  setTheme: (theme: 'light' | 'dark' | 'system') => void
  toggleSidebar: () => void
}

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      theme: 'system',
      sidebarOpen: true,
      setTheme: (theme) => set({ theme }),
      toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
    }),
    {
      name: 'settings-storage', // localStorage key
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({ theme: state.theme }), // Only persist theme
    }
  )
)
```

---

## Immer Middleware (Immutable Updates)

```typescript
import { create } from 'zustand'
import { immer } from 'zustand/middleware/immer'

interface TodoStore {
  todos: Todo[]
  addTodo: (text: string) => void
  toggleTodo: (id: string) => void
  removeTodo: (id: string) => void
}

export const useTodoStore = create<TodoStore>()(
  immer((set) => ({
    todos: [],

    addTodo: (text) => set((state) => {
      state.todos.push({ id: crypto.randomUUID(), text, done: false })
    }),

    toggleTodo: (id) => set((state) => {
      const todo = state.todos.find((t) => t.id === id)
      if (todo) todo.done = !todo.done
    }),

    removeTodo: (id) => set((state) => {
      state.todos = state.todos.filter((t) => t.id !== id)
    }),
  }))
)
```

---

## DevTools

```typescript
import { create } from 'zustand'
import { devtools } from 'zustand/middleware'

export const useStore = create<Store>()(
  devtools(
    (set) => ({
      // Store definition
    }),
    { name: 'MyStore' } // Shows in Redux DevTools
  )
)

// Combine middlewares
export const useStore = create<Store>()(
  devtools(
    persist(
      immer((set) => ({
        // Store definition
      })),
      { name: 'storage-key' }
    ),
    { name: 'MyStore' }
  )
)
```

---

## Slices Pattern (Large Stores)

```typescript
// stores/slices/userSlice.ts
import { StateCreator } from 'zustand'

export interface UserSlice {
  user: User | null
  setUser: (user: User) => void
  logout: () => void
}

export const createUserSlice: StateCreator<UserSlice> = (set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: () => set({ user: null }),
})

// stores/slices/cartSlice.ts
export interface CartSlice {
  items: CartItem[]
  addItem: (item: CartItem) => void
  removeItem: (id: string) => void
}

export const createCartSlice: StateCreator<CartSlice> = (set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  removeItem: (id) => set((state) => ({ items: state.items.filter((i) => i.id !== id) })),
})

// stores/index.ts
import { create } from 'zustand'
import { createUserSlice, UserSlice } from './slices/userSlice'
import { createCartSlice, CartSlice } from './slices/cartSlice'

type Store = UserSlice & CartSlice

export const useStore = create<Store>()((...a) => ({
  ...createUserSlice(...a),
  ...createCartSlice(...a),
}))
```

---

## Actions Outside React

```typescript
// Access store outside components
const { user, setUser } = useUserStore.getState()

// Subscribe to changes
const unsubscribe = useUserStore.subscribe(
  (state) => console.log('State changed:', state)
)

// Subscribe with selector
const unsubscribe = useUserStore.subscribe(
  (state) => state.user,
  (user) => console.log('User changed:', user)
)
```

---

## SSR / Hydration (Next.js)

```typescript
// stores/counter.ts
import { create } from 'zustand'

interface CounterStore {
  count: number
  increment: () => void
}

export const useCounterStore = create<CounterStore>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}))

// For SSR, use a provider pattern
'use client'

import { useRef } from 'react'
import { useCounterStore } from '@/stores/counter'

interface Props {
  initialCount: number
  children: React.ReactNode
}

export function CounterProvider({ initialCount, children }: Props) {
  const initialized = useRef(false)

  if (!initialized.current) {
    useCounterStore.setState({ count: initialCount })
    initialized.current = true
  }

  return <>{children}</>
}
```

---

## Computed Values (Derived State)

```typescript
import { create } from 'zustand'

interface CartStore {
  items: CartItem[]
  // Computed getters
  get totalItems(): number
  get totalPrice(): number
}

export const useCartStore = create<CartStore>()((set, get) => ({
  items: [],

  get totalItems() {
    return get().items.reduce((sum, item) => sum + item.quantity, 0)
  },

  get totalPrice() {
    return get().items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  },
}))

// Or use selectors
const totalItems = useCartStore((state) =>
  state.items.reduce((sum, item) => sum + item.quantity, 0)
)
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Selecting entire store | Use selectors: `useStore(s => s.count)` |
| Not using shallow compare | Use `useShallow` for object selectors |
| Mutating state directly | Use `immer` or spread operator |
| Missing persistence | Add `persist` middleware |
| Large re-renders | Split into multiple stores or slices |

---

## Quick Reference

| Pattern | Code |
|---------|------|
| Create store | `create<T>((set) => ({ ... }))` |
| Update state | `set({ key: value })` |
| Update with prev | `set((state) => ({ count: state.count + 1 }))` |
| Get state | `get()` inside actions |
| Select state | `useStore((state) => state.key)` |
| Persist | `persist((set) => (...), { name: 'key' })` |
| DevTools | `devtools((set) => (...))` |
| Immer | `immer((set) => (...))` |

## References

- [Zustand Docs](https://zustand-demo.pmnd.rs)
- [GitHub](https://github.com/pmndrs/zustand)
