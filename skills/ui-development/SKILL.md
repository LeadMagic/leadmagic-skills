---
name: ui-development
description: Best practices for shadcn/ui, Tailwind CSS v4, Framer Motion, and Recharts. Use when creating React components, styling, animations, or data visualization. Triggers on "shadcn", "Tailwind", "Framer Motion", "charts", "UI components".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "2.1.0"
  context7: framer/motion
---

# UI Development Best Practices

Modern UI patterns with shadcn/ui, Tailwind CSS v4, Framer Motion, and Recharts.

## Tailwind CSS v4 (Major Rewrite)

| Feature | Description |
|---------|-------------|
| **CSS-first config** | Configure via CSS, no `tailwind.config.js` needed |
| **`@theme` directive** | Define design tokens in CSS |
| **OKLCH colors** | Wider gamut, more vivid palette |
| **Container queries** | Built-in `@container`, no plugin |
| **3D transforms** | `rotate-x-*`, `translate-z-*`, `perspective-*` |
| **`@starting-style`** | CSS entry animations without JS |
| **`not-*` variant** | `:not()` pseudo-class support |
| **Dynamic values** | `grid-cols-15`, `mt-17` work without config |

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

### CSS Configuration (No JS Config!)

```css
/* globals.css - Tailwind v4 */
@import "tailwindcss";

@theme {
  --color-primary: oklch(0.45 0.18 265);
  --color-background: oklch(1 0 0);
  --font-sans: "Inter", sans-serif;
  --breakpoint-3xl: 1920px;
}

.dark {
  --color-background: oklch(0.15 0.02 265);
}
```

### New v4 Features

```tsx
{/* Container queries - built-in */}
<div className="@container">
  <div className="grid grid-cols-1 @sm:grid-cols-3 @lg:grid-cols-4" />
</div>

{/* Dynamic values - no config needed */}
<div className="grid-cols-15 mt-17 w-29" />

{/* 3D transforms */}
<div className="perspective-distant rotate-x-12 rotate-z-6 transform-3d" />

{/* not-* variant */}
<div className="not-hover:opacity-75" />

{/* @starting-style for entry animations */}
<div className="transition-discrete starting:open:opacity-0" />

{/* Gradient improvements */}
<div className="bg-linear-45 from-indigo-500 to-pink-500" />
<div className="bg-conic from-red-500 to-red-500" />
<div className="bg-radial-[at_25%_25%] from-white to-zinc-900" />
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
