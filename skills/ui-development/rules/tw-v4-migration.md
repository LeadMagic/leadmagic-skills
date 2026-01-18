---
title: Tailwind CSS v4 Migration
impact: CRITICAL
impactDescription: Breaking changes in Tailwind v4 require updates
tags: tailwind, v4, migration, config
---

## Tailwind CSS v4 Migration

Tailwind v4 introduces significant changes including the `@theme` directive, inline configuration, and new component patterns. shadcn/ui now supports Tailwind v4 and React 19.

**Key Changes in Tailwind v4:**

1. **`@theme` directive** - Replaces `theme.extend` in tailwind.config
2. **Inline theme configuration** - CSS-first configuration
3. **`data-slot` attribute** - Added to every shadcn primitive
4. **Removed `forwardRef`** - React 19 compatibility
5. **New default style** - "new-york" replaces "default"
6. **Deprecations** - `toast` component replaced by `sonner`

**Old Tailwind v3 Config:**

```javascript
// tailwind.config.js (v3)
module.exports = {
  darkMode: ['class'],
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}
```

**New Tailwind v4 with @theme:**

```css
/* globals.css (v4) */
@import "tailwindcss";
@import "tailwindcss-animate";

@theme {
  --color-border: hsl(var(--border));
  --color-background: hsl(var(--background));
  --color-foreground: hsl(var(--foreground));
  --color-primary: hsl(var(--primary));
  --color-primary-foreground: hsl(var(--primary-foreground));

  --radius-lg: var(--radius);
  --radius-md: calc(var(--radius) - 2px);
}

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --border: 217.2 32.6% 17.5%;
  }
}
```

**Removed forwardRef (React 19):**

```typescript
// Old (React 18 with forwardRef)
const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, ...props }, ref) => {
    return <button ref={ref} className={className} {...props} />
  }
)
Button.displayName = 'Button'

// New (React 19 - ref is a regular prop)
function Button({ className, ref, ...props }: ButtonProps) {
  return <button ref={ref} className={className} {...props} />
}
```

**data-slot attribute:**

```typescript
// Every shadcn primitive now has data-slot for styling
function Card({ className, ...props }: CardProps) {
  return (
    <div
      data-slot="card"  // New in v4
      className={cn("rounded-lg border bg-card", className)}
      {...props}
    />
  )
}

// Style with data attributes
// [data-slot="card"]:hover { ... }
```

**Toast → Sonner Migration:**

```typescript
// Old (toast component - DEPRECATED)
import { toast } from '@/components/ui/toast'
toast({ title: 'Success', description: 'Item saved' })

// New (sonner)
import { toast } from 'sonner'
toast.success('Item saved')

// In layout, add Toaster
import { Toaster } from 'sonner'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Toaster />
      </body>
    </html>
  )
}
```

**New "new-york" style:**

```bash
# When initializing shadcn, "new-york" is now the default
npx shadcn@latest init

# Explicitly choose style
npx shadcn@latest init --style new-york
npx shadcn@latest init --style default  # Old style
```

**Migration Checklist:**

- [ ] Update to Tailwind v4: `npm install tailwindcss@4`
- [ ] Convert `tailwind.config.js` to `@theme` in CSS
- [ ] Remove `forwardRef` from components (React 19)
- [ ] Update components to use `data-slot`
- [ ] Replace `toast` with `sonner`
- [ ] Run `npx shadcn@latest diff` to see component changes
- [ ] Update to new-york style if desired
