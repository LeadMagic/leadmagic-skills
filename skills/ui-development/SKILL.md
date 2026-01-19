---
name: ui-development
description: Best practices for shadcn/ui, Tailwind CSS v4, Framer Motion, and Recharts. Use when creating React components, styling, animations, or data visualization. Triggers on "shadcn", "Tailwind", "Framer Motion", "charts", "UI components".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "2.0.0"
---

# UI Development Best Practices

Modern UI patterns with shadcn/ui, Tailwind CSS v4, Framer Motion, and Recharts.

## What's New

- **Tailwind CSS v4** - `@import "tailwindcss"` replaces `@tailwind`
- **shadcn/ui** - Supports Base UI as alternative to Radix
- **CLI** - `npx shadcn@latest` with improved prompts

## Rule Categories

| Category | Impact | Rules |
|----------|--------|-------|
| shadcn/ui | CRITICAL | `shadcn-*` (10 rules) |
| Tailwind | CRITICAL | `tw-*` (4 rules) |
| Animation | HIGH | `motion-*` (2 rules) |
| Accessibility | HIGH | `a11y-*` (1 rule) |

## Packages

```bash
# Core utilities
npm install class-variance-authority clsx tailwind-merge lucide-react

# Forms
npm install react-hook-form @hookform/resolvers zod

# Data tables
npm install @tanstack/react-table

# Charts & Toast
npm install recharts sonner
```

---

## shadcn/ui Setup

```bash
npx shadcn@latest init
npx shadcn@latest add button card dialog input
```

### cn() Utility

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

### Component Variants (cva)

```typescript
import { cva, type VariantProps } from "class-variance-authority"

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md font-medium transition-colors",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        outline: "border border-input bg-background hover:bg-accent",
        ghost: "hover:bg-accent hover:text-accent-foreground",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 px-3",
        lg: "h-11 px-8",
      },
    },
    defaultVariants: { variant: "default", size: "default" },
  }
)
```

See `rules/shadcn-*.md` for detailed component patterns.

---

## Tailwind CSS v4

### CSS Configuration

```css
/* globals.css - Tailwind v4 */
@import "tailwindcss";

@theme {
  --color-primary: 222.2 47.4% 11.2%;
  --color-background: 0 0% 100%;
  --font-sans: "Inter", sans-serif;
}

.dark {
  --color-background: 222.2 84% 4.9%;
}
```

### Responsive (Mobile-first)

```tsx
<div className="p-4 md:p-6 lg:p-8">
  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    {/* Content */}
  </div>
</div>
```

### Dark Mode

```tsx
<div className="bg-white dark:bg-slate-900 text-slate-900 dark:text-white">
  <button className="bg-blue-500 hover:bg-blue-600 dark:bg-blue-600 dark:hover:bg-blue-700">
    Click me
  </button>
</div>
```

See `rules/tw-*.md` for detailed patterns.

---

## Framer Motion

```tsx
import { motion } from "framer-motion"

const variants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
}

export function AnimatedCard({ children }) {
  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={variants}
      transition={{ duration: 0.3 }}
    >
      {children}
    </motion.div>
  )
}
```

### Respect Reduced Motion

```tsx
import { useReducedMotion } from "framer-motion"

function Component() {
  const shouldReduceMotion = useReducedMotion()

  return (
    <motion.div
      animate={{ x: shouldReduceMotion ? 0 : 100 }}
      transition={{ duration: shouldReduceMotion ? 0 : 0.3 }}
    />
  )
}
```

See `rules/motion-*.md` for detailed patterns.

---

## Forms (React Hook Form + Zod)

```tsx
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

export function LoginForm() {
  const form = useForm({
    resolver: zodResolver(schema),
    defaultValues: { email: "", password: "" },
  })

  const onSubmit = (data: z.infer<typeof schema>) => {
    console.log(data)
  }

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <input {...form.register("email")} />
      {form.formState.errors.email && <p>{form.formState.errors.email.message}</p>}
      <button type="submit">Submit</button>
    </form>
  )
}
```

See `rules/shadcn-forms.md` for shadcn Form component patterns.

---

## Data Tables

```tsx
import { useReactTable, getCoreRowModel, flexRender } from "@tanstack/react-table"

const columns = [
  { accessorKey: "name", header: "Name" },
  { accessorKey: "email", header: "Email" },
]

function DataTable({ data }) {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <table>
      <thead>
        {table.getHeaderGroups().map(hg => (
          <tr key={hg.id}>
            {hg.headers.map(h => (
              <th key={h.id}>{flexRender(h.column.columnDef.header, h.getContext())}</th>
            ))}
          </tr>
        ))}
      </thead>
      <tbody>
        {table.getRowModel().rows.map(row => (
          <tr key={row.id}>
            {row.getVisibleCells().map(cell => (
              <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  )
}
```

See `rules/shadcn-tables.md` for complete patterns.

---

## Charts (Recharts)

```tsx
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts"

function Chart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={400}>
      <LineChart data={data}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="name" />
        <YAxis />
        <Tooltip />
        <Line type="monotone" dataKey="value" stroke="hsl(var(--primary))" />
      </LineChart>
    </ResponsiveContainer>
  )
}
```

See `rules/shadcn-charts.md` for complete patterns.

---

## Quick Reference

| Pattern | Code |
|---------|------|
| Install component | `npx shadcn@latest add [component]` |
| Merge classes | `cn("base", condition && "conditional")` |
| Variants | `cva("base", { variants: {...} })` |
| Dark mode | `dark:bg-slate-900` |
| Responsive | `sm:`, `md:`, `lg:`, `xl:` |
| Animation | `motion.div` with `variants` |
| Reduced motion | `useReducedMotion()` |
