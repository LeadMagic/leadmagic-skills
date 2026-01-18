---
title: Radix UI Primitives
impact: HIGH
impactDescription: Accessible, unstyled components as foundation
tags: radix, primitives, accessibility, components
---

## Radix UI Primitives

shadcn/ui is built on Radix UI primitives. Understanding Radix helps you customize components effectively.

**What Radix Provides:**

- Fully accessible (ARIA compliant)
- Keyboard navigation built-in
- Focus management
- Screen reader support
- Unstyled (you control appearance)
- Composable parts

**Radix Component Structure:**

```typescript
// Radix components have a Root and multiple Parts
import * as Dialog from '@radix-ui/react-dialog'

// Root provides context
<Dialog.Root>
  // Trigger opens the dialog
  <Dialog.Trigger>Open</Dialog.Trigger>

  // Portal renders outside DOM hierarchy
  <Dialog.Portal>
    // Overlay is the backdrop
    <Dialog.Overlay />

    // Content is the dialog itself
    <Dialog.Content>
      <Dialog.Title>Title</Dialog.Title>
      <Dialog.Description>Description</Dialog.Description>
      <Dialog.Close>Close</Dialog.Close>
    </Dialog.Content>
  </Dialog.Portal>
</Dialog.Root>
```

**shadcn Wraps Radix with Styling:**

```typescript
// components/ui/dialog.tsx
import * as DialogPrimitive from "@radix-ui/react-dialog"
import { cn } from "@/lib/utils"

const Dialog = DialogPrimitive.Root
const DialogTrigger = DialogPrimitive.Trigger
const DialogPortal = DialogPrimitive.Portal
const DialogClose = DialogPrimitive.Close

const DialogOverlay = React.forwardRef<
  React.ElementRef<typeof DialogPrimitive.Overlay>,
  React.ComponentPropsWithoutRef<typeof DialogPrimitive.Overlay>
>(({ className, ...props }, ref) => (
  <DialogPrimitive.Overlay
    ref={ref}
    className={cn(
      "fixed inset-0 z-50 bg-black/80",
      "data-[state=open]:animate-in data-[state=closed]:animate-out",
      "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
      className
    )}
    {...props}
  />
))

const DialogContent = React.forwardRef<
  React.ElementRef<typeof DialogPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof DialogPrimitive.Content>
>(({ className, children, ...props }, ref) => (
  <DialogPortal>
    <DialogOverlay />
    <DialogPrimitive.Content
      ref={ref}
      className={cn(
        "fixed left-[50%] top-[50%] z-50 translate-x-[-50%] translate-y-[-50%]",
        "w-full max-w-lg border bg-background p-6 shadow-lg",
        "data-[state=open]:animate-in data-[state=closed]:animate-out",
        "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
        "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        className
      )}
      {...props}
    >
      {children}
      <DialogPrimitive.Close className="absolute right-4 top-4 opacity-70 hover:opacity-100">
        <X className="h-4 w-4" />
        <span className="sr-only">Close</span>
      </DialogPrimitive.Close>
    </DialogPrimitive.Content>
  </DialogPortal>
))
```

**Data Attributes for Styling:**

```typescript
// Radix exposes state via data attributes
// Style based on component state without JavaScript

// Dialog overlay when open/closed
<DialogOverlay className="
  data-[state=open]:animate-in
  data-[state=closed]:animate-out
  data-[state=open]:fade-in-0
  data-[state=closed]:fade-out-0
" />

// Accordion item when open/closed
<AccordionContent className="
  data-[state=open]:animate-accordion-down
  data-[state=closed]:animate-accordion-up
" />

// Checkbox when checked/unchecked
<Checkbox className="
  data-[state=checked]:bg-primary
  data-[state=unchecked]:bg-transparent
" />

// Menu item when highlighted
<DropdownMenuItem className="
  data-[highlighted]:bg-accent
  data-[highlighted]:text-accent-foreground
" />

// Disabled state
<Button className="
  data-[disabled]:opacity-50
  data-[disabled]:pointer-events-none
" />
```

**Common Radix Packages:**

```typescript
// Interactive components
import * as Accordion from '@radix-ui/react-accordion'
import * as AlertDialog from '@radix-ui/react-alert-dialog'
import * as Dialog from '@radix-ui/react-dialog'
import * as DropdownMenu from '@radix-ui/react-dropdown-menu'
import * as Popover from '@radix-ui/react-popover'
import * as Select from '@radix-ui/react-select'
import * as Tabs from '@radix-ui/react-tabs'
import * as Tooltip from '@radix-ui/react-tooltip'

// Form components
import * as Checkbox from '@radix-ui/react-checkbox'
import * as Label from '@radix-ui/react-label'
import * as RadioGroup from '@radix-ui/react-radio-group'
import * as Slider from '@radix-ui/react-slider'
import * as Switch from '@radix-ui/react-switch'

// Navigation
import * as NavigationMenu from '@radix-ui/react-navigation-menu'
import * as Menubar from '@radix-ui/react-menubar'

// Layout
import * as ScrollArea from '@radix-ui/react-scroll-area'
import * as Separator from '@radix-ui/react-separator'

// Utility
import { Slot } from '@radix-ui/react-slot'
```

**The Slot Component:**

```typescript
import { Slot } from '@radix-ui/react-slot'

// Slot merges props onto its child
// Used for asChild pattern

interface ButtonProps {
  asChild?: boolean
  children: React.ReactNode
}

function Button({ asChild, children, ...props }: ButtonProps) {
  const Comp = asChild ? Slot : 'button'
  return <Comp {...props}>{children}</Comp>
}

// Usage:
<Button>Click me</Button>           // Renders <button>
<Button asChild>
  <Link href="/home">Go Home</Link> // Renders <a> with button styles
</Button>
```

**Controlled vs Uncontrolled:**

```typescript
// Uncontrolled - Radix manages state internally
<Dialog.Root>
  <Dialog.Trigger>Open</Dialog.Trigger>
  <Dialog.Content>...</Dialog.Content>
</Dialog.Root>

// Controlled - You manage state
const [open, setOpen] = useState(false)

<Dialog.Root open={open} onOpenChange={setOpen}>
  <Dialog.Trigger>Open</Dialog.Trigger>
  <Dialog.Content>
    <button onClick={() => setOpen(false)}>
      Close programmatically
    </button>
  </Dialog.Content>
</Dialog.Root>
```

**Accessibility Built-in:**

```typescript
// Radix handles these automatically:
// - ARIA attributes
// - Keyboard navigation (Tab, Arrow keys, Escape)
// - Focus trapping in modals
// - Focus restoration on close
// - Screen reader announcements

// You just need to provide labels
<Dialog.Root>
  <Dialog.Trigger>Open Settings</Dialog.Trigger>
  <Dialog.Content aria-describedby={undefined}>
    <Dialog.Title>Settings</Dialog.Title>
    <Dialog.Description>
      Manage your account settings
    </Dialog.Description>
  </Dialog.Content>
</Dialog.Root>
```
