---
title: shadcn/ui Required Packages
impact: CRITICAL
impactDescription: Complete dependency setup for shadcn/ui
tags: shadcn, packages, dependencies, setup
---

## shadcn/ui Required Packages

shadcn/ui requires several packages to work correctly. Install all core dependencies before adding components.

**Core Dependencies:**

```bash
# Core utilities (required)
npm install class-variance-authority clsx tailwind-merge

# Icons (commonly used)
npm install lucide-react

# Animations (Tailwind v4)
npm install tw-animate-css

# Or for Tailwind v3
npm install tailwindcss-animate
```

**Complete Package List:**

```json
{
  "dependencies": {
    // Core styling utilities
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.2.0",

    // Icons
    "lucide-react": "^0.300.0",

    // Radix UI primitives (added per component)
    "@radix-ui/react-accordion": "^1.1.0",
    "@radix-ui/react-alert-dialog": "^1.0.0",
    "@radix-ui/react-avatar": "^1.0.0",
    "@radix-ui/react-checkbox": "^1.0.0",
    "@radix-ui/react-collapsible": "^1.0.0",
    "@radix-ui/react-context-menu": "^2.1.0",
    "@radix-ui/react-dialog": "^1.0.0",
    "@radix-ui/react-dropdown-menu": "^2.0.0",
    "@radix-ui/react-hover-card": "^1.0.0",
    "@radix-ui/react-label": "^2.0.0",
    "@radix-ui/react-menubar": "^1.0.0",
    "@radix-ui/react-navigation-menu": "^1.1.0",
    "@radix-ui/react-popover": "^1.0.0",
    "@radix-ui/react-progress": "^1.0.0",
    "@radix-ui/react-radio-group": "^1.1.0",
    "@radix-ui/react-scroll-area": "^1.0.0",
    "@radix-ui/react-select": "^2.0.0",
    "@radix-ui/react-separator": "^1.0.0",
    "@radix-ui/react-slider": "^1.1.0",
    "@radix-ui/react-slot": "^1.0.0",
    "@radix-ui/react-switch": "^1.0.0",
    "@radix-ui/react-tabs": "^1.0.0",
    "@radix-ui/react-toast": "^1.1.0",
    "@radix-ui/react-toggle": "^1.0.0",
    "@radix-ui/react-toggle-group": "^1.0.0",
    "@radix-ui/react-tooltip": "^1.0.0",

    // Form handling
    "react-hook-form": "^7.50.0",
    "@hookform/resolvers": "^3.3.0",
    "zod": "^3.22.0",

    // Date picker
    "date-fns": "^3.0.0",
    "react-day-picker": "^8.10.0",

    // Charts
    "recharts": "^2.12.0",

    // Toast notifications (replacing deprecated toast)
    "sonner": "^1.4.0",

    // Data tables
    "@tanstack/react-table": "^8.11.0",

    // Command palette
    "cmdk": "^0.2.0",

    // Carousel
    "embla-carousel-react": "^8.0.0",

    // Resizable panels
    "react-resizable-panels": "^2.0.0",

    // Drawer (mobile)
    "vaul": "^0.9.0"
  },
  "devDependencies": {
    // Tailwind
    "tailwindcss": "^4.0.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0",

    // Animations
    "tw-animate-css": "^1.0.0"
  }
}
```

**The `cn()` Utility Function:**

```typescript
// lib/utils.ts - Required for all shadcn components
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

**Why Each Package:**

| Package | Purpose |
|---------|---------|
| `class-variance-authority` | Type-safe component variants (cva) |
| `clsx` | Conditional class names |
| `tailwind-merge` | Merge conflicting Tailwind classes |
| `lucide-react` | Icon components |
| `@radix-ui/*` | Accessible UI primitives |
| `react-hook-form` | Form state management |
| `zod` | Schema validation |
| `sonner` | Toast notifications |
| `recharts` | Data visualization |
| `cmdk` | Command palette (⌘K) |
| `date-fns` | Date manipulation |
| `vaul` | Drawer component (mobile) |

**Initialization:**

```bash
# Automatic setup (recommended)
npx shadcn@latest init

# Prompts for:
# - Style: new-york (default) or default
# - Base color: slate, gray, zinc, neutral, stone
# - CSS variables: yes (recommended)
# - Tailwind config location
# - Components location
# - Utils location
```

**components.json Configuration:**

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "app/globals.css",
    "baseColor": "zinc",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  }
}
```

**Adding Components:**

```bash
# Add individual components
npx shadcn@latest add button
npx shadcn@latest add card dialog input

# Add multiple at once
npx shadcn@latest add accordion alert avatar badge

# Add all components
npx shadcn@latest add --all

# Update existing components
npx shadcn@latest add button --overwrite
```
