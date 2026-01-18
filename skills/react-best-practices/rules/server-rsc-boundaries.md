---
title: Optimize Server/Client Component Boundaries
impact: HIGH
impactDescription: Reduce client bundle and hydration cost
tags: rsc, server-components, client-components, next-js
---

## Optimize Server/Client Component Boundaries

Server Components run only on the server and ship zero JavaScript to the client. Place the `'use client'` boundary as deep as possible to minimize client bundle size.

**Incorrect (boundary too high):**

```typescript
// app/page.tsx
'use client' // ❌ Entire page is now client-side

import { useState } from 'react'
import { ProductList } from './product-list'
import { Header } from './header'
import { Footer } from './footer'

export default function Page() {
  const [filter, setFilter] = useState('')

  return (
    <div>
      <Header />
      <input value={filter} onChange={e => setFilter(e.target.value)} />
      <ProductList filter={filter} />
      <Footer />
    </div>
  )
}
```

**Correct (boundary pushed down):**

```typescript
// app/page.tsx (Server Component - no 'use client')
import { ProductSection } from './product-section'
import { Header } from './header'
import { Footer } from './footer'

export default function Page() {
  return (
    <div>
      <Header />       {/* Server Component */}
      <ProductSection /> {/* Client Component boundary here */}
      <Footer />       {/* Server Component */}
    </div>
  )
}

// app/product-section.tsx
'use client' // Only this component and its children are client-side

import { useState } from 'react'
import { ProductList } from './product-list'

export function ProductSection() {
  const [filter, setFilter] = useState('')

  return (
    <div>
      <input value={filter} onChange={e => setFilter(e.target.value)} />
      <ProductList filter={filter} />
    </div>
  )
}
```

**Server Components for Data Fetching:**

```typescript
// app/dashboard/page.tsx (Server Component)
import { getUser, getStats, getNotifications } from '@/lib/data'
import { DashboardClient } from './dashboard-client'

export default async function DashboardPage() {
  // Parallel data fetching on the server
  const [user, stats, notifications] = await Promise.all([
    getUser(),
    getStats(),
    getNotifications(),
  ])

  return (
    <div>
      {/* Static server-rendered content */}
      <h1>Welcome, {user.name}</h1>

      {/* Pass serialized data to client component */}
      <DashboardClient
        initialStats={stats}
        initialNotifications={notifications}
      />
    </div>
  )
}

// app/dashboard/dashboard-client.tsx
'use client'

import { useState } from 'react'

export function DashboardClient({
  initialStats,
  initialNotifications
}: Props) {
  const [stats, setStats] = useState(initialStats)
  // Interactive features here
  return <div>...</div>
}
```

**Composing Server and Client:**

```typescript
// Server Components can render Client Components
// Client Components can render Server Components via children

// layout.tsx (Server Component)
import { Sidebar } from './sidebar' // Client Component
import { Navigation } from './navigation' // Server Component

export default function Layout({ children }) {
  return (
    <div className="flex">
      <Sidebar>
        {/* Server Component passed as children to Client Component */}
        <Navigation />
      </Sidebar>
      <main>{children}</main>
    </div>
  )
}

// sidebar.tsx
'use client'

export function Sidebar({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(true)

  return (
    <aside className={open ? 'w-64' : 'w-16'}>
      <button onClick={() => setOpen(!open)}>Toggle</button>
      {children} {/* Server Component renders here */}
    </aside>
  )
}
```

**Context Providers Must Be Client:**

```typescript
// providers.tsx
'use client'

import { ThemeProvider } from 'next-themes'
import { QueryClientProvider } from '@tanstack/react-query'

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        {children}
      </ThemeProvider>
    </QueryClientProvider>
  )
}

// layout.tsx (Server Component)
import { Providers } from './providers'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <Providers>
          {children} {/* Can still be Server Components */}
        </Providers>
      </body>
    </html>
  )
}
```

**What Requires Client Components:**

| Feature | Server | Client |
|---------|--------|--------|
| useState, useEffect | ❌ | ✅ |
| Event handlers (onClick) | ❌ | ✅ |
| Browser APIs (window, localStorage) | ❌ | ✅ |
| Context (createContext, useContext) | ❌ | ✅ |
| Custom hooks with state | ❌ | ✅ |
| async/await data fetching | ✅ | ❌ (use SWR/React Query) |
| Direct database access | ✅ | ❌ |
| Access secrets/env vars | ✅ | ❌ |
| Large dependencies | ✅ | Adds to bundle |
