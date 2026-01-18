---
title: Proper shadcn/ui Component Installation
impact: CRITICAL
impactDescription: Components must be owned, not imported as dependencies
tags: shadcn, components, installation
---

## Proper shadcn/ui Component Installation

shadcn/ui is not a component library you install as a dependency. Components are copied into your project, giving you full ownership and customization control.

**Incorrect (treating as npm package):**

```typescript
// This doesn't exist!
import { Button } from '@shadcn/ui'
import { Dialog } from 'shadcn-ui/components'

// Or trying to install via npm
// npm install shadcn-ui ❌
```

**Correct (using CLI to add components):**

```bash
# Initialize shadcn/ui in your project
npx shadcn@latest init

# Add specific components
npx shadcn@latest add button
npx shadcn@latest add dialog
npx shadcn@latest add card input label

# Add multiple at once
npx shadcn@latest add accordion alert-dialog avatar badge
```

```typescript
// Import from your own components directory
import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogTrigger } from "@/components/ui/dialog"
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
```

**Project structure after installation:**

```
src/
├── components/
│   └── ui/
│       ├── button.tsx      # You own this!
│       ├── card.tsx        # Customize freely
│       ├── dialog.tsx      # Full control
│       └── ...
├── lib/
│   └── utils.ts            # cn() helper
└── ...
```

**The philosophy:**

- You own the code, not a dependency
- Customize components directly in your codebase
- No version lock-in or breaking updates
- Full TypeScript support with your project config
- Components use Radix UI primitives underneath

**Customizing after installation:**

```typescript
// components/ui/button.tsx - modify directly!
const buttonVariants = cva(
  "inline-flex items-center justify-center...",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        // Add your own variants!
        brand: "bg-gradient-to-r from-purple-500 to-pink-500 text-white",
        success: "bg-green-500 text-white hover:bg-green-600",
      },
      size: {
        default: "h-10 px-4 py-2",
        // Add your own sizes!
        xs: "h-7 px-2 text-xs",
        xl: "h-14 px-8 text-lg",
      },
    },
  }
)
```
