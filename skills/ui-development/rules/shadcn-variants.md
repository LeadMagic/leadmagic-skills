---
title: Use CVA for Component Variants
impact: CRITICAL
impactDescription: Type-safe, maintainable component variants
tags: shadcn, cva, variants, styling
---

## Use CVA for Component Variants

Class Variance Authority (cva) provides type-safe variant management for components. Use it instead of conditional class logic.

**Incorrect (manual conditional classes):**

```typescript
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
}

function Button({ variant = 'primary', size = 'md', ...props }: ButtonProps) {
  // Messy, hard to maintain, easy to miss combinations
  let classes = 'inline-flex items-center justify-center rounded-md font-medium'

  if (variant === 'primary') {
    classes += ' bg-blue-500 text-white hover:bg-blue-600'
  } else if (variant === 'secondary') {
    classes += ' bg-gray-200 text-gray-900 hover:bg-gray-300'
  } else if (variant === 'danger') {
    classes += ' bg-red-500 text-white hover:bg-red-600'
  }

  if (size === 'sm') {
    classes += ' h-8 px-3 text-sm'
  } else if (size === 'md') {
    classes += ' h-10 px-4 text-base'
  } else if (size === 'lg') {
    classes += ' h-12 px-6 text-lg'
  }

  return <button className={classes} {...props} />
}
```

**Correct (using cva):**

```typescript
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  // Base classes applied to all variants
  "inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    // Compound variants for specific combinations
    compoundVariants: [
      {
        variant: "destructive",
        size: "lg",
        className: "font-bold", // Extra emphasis for large destructive buttons
      },
    ],
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

// Type-safe props derived from variants
interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
```

**Usage with full type safety:**

```typescript
// TypeScript knows all valid variants
<Button variant="destructive" size="lg">Delete</Button>
<Button variant="ghost" size="icon"><Icon /></Button>
<Button variant="outline">Cancel</Button>

// Type error: invalid variant
<Button variant="invalid">Error</Button> // ❌ TypeScript error
```

**The cn() utility:**

```typescript
// lib/utils.ts
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

This utility:
- Merges class names conditionally (clsx)
- Resolves Tailwind conflicts properly (tailwind-merge)
- Allows overriding via className prop
