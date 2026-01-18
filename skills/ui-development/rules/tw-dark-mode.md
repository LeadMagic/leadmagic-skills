---
title: Implement Dark Mode Properly
impact: HIGH
impactDescription: Accessible, system-aware theming
tags: tailwind, dark-mode, theming
---

## Implement Dark Mode Properly

Use CSS variables with Tailwind's dark mode for proper theme support. This enables system preference detection and manual toggle.

**Incorrect (hardcoded colors without dark mode):**

```typescript
function Card() {
  return (
    <div className="bg-white text-gray-900 border-gray-200">
      {/* No dark mode support */}
    </div>
  )
}
```

**Incorrect (inline dark mode without system):**

```typescript
function Card() {
  return (
    // Works but doesn't respect system preference
    <div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
      {/* Repetitive, hard to maintain */}
    </div>
  )
}
```

**Correct (CSS variables with semantic colors):**

```css
/* globals.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --border: 214.3 31.8% 91.4%;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --border: 217.2 32.6% 17.5%;
  }
}
```

```typescript
// tailwind.config.ts
export default {
  darkMode: ["class"],
  theme: {
    extend: {
      colors: {
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        border: "hsl(var(--border))",
      },
    },
  },
}
```

```typescript
// Now use semantic color names
function Card() {
  return (
    <div className="bg-card text-card-foreground border-border rounded-lg p-6">
      <h2 className="text-foreground">Title</h2>
      <p className="text-muted-foreground">Subtitle</p>
      <button className="bg-primary text-primary-foreground">Action</button>
    </div>
  )
}
```

**Theme provider with next-themes:**

```typescript
// app/providers.tsx
'use client'

import { ThemeProvider } from 'next-themes'

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      disableTransitionOnChange
    >
      {children}
    </ThemeProvider>
  )
}

// components/ThemeToggle.tsx
'use client'

import { useTheme } from 'next-themes'
import { Moon, Sun } from 'lucide-react'
import { Button } from '@/components/ui/button'

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
    >
      <Sun className="h-5 w-5 rotate-0 scale-100 transition-transform dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-5 w-5 rotate-90 scale-0 transition-transform dark:rotate-0 dark:scale-100" />
      <span className="sr-only">Toggle theme</span>
    </Button>
  )
}
```

Benefits:
- Single source of truth for colors
- System preference respected
- No repeated dark: prefixes
- Easy to add more themes (e.g., .theme-purple)
