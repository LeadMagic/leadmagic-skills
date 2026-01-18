---
title: Ensure Keyboard Navigation
impact: HIGH
impactDescription: Essential for users who can't use a mouse
tags: accessibility, keyboard, navigation
---

## Ensure Keyboard Navigation

All interactive elements must be accessible via keyboard. Users should be able to navigate with Tab, activate with Enter/Space, and dismiss with Escape.

**Incorrect (click-only interactions):**

```typescript
// Non-focusable, no keyboard support
function Card({ onClick }) {
  return (
    <div onClick={onClick} className="cursor-pointer">
      {/* Can't be reached with Tab key */}
      Click me
    </div>
  )
}

// Custom dropdown without keyboard support
function Dropdown() {
  const [open, setOpen] = useState(false)

  return (
    <div>
      <div onClick={() => setOpen(!open)}>Menu</div>
      {open && (
        <div>
          {/* No arrow key navigation */}
          <div onClick={() => handleSelect('a')}>Option A</div>
          <div onClick={() => handleSelect('b')}>Option B</div>
        </div>
      )}
    </div>
  )
}
```

**Correct (full keyboard support):**

```typescript
// Use semantic elements when possible
function Card({ onClick }) {
  return (
    <button
      onClick={onClick}
      className="text-left w-full p-4 rounded-lg hover:bg-accent focus-visible:ring-2"
    >
      {/* Automatically focusable and keyboard accessible */}
      Click me
    </button>
  )
}

// Or add proper attributes to divs
function ClickableCard({ onClick }) {
  return (
    <div
      role="button"
      tabIndex={0}
      onClick={onClick}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault()
          onClick()
        }
      }}
      className="cursor-pointer focus-visible:ring-2 focus-visible:ring-ring rounded-lg"
    >
      Click me
    </div>
  )
}

// Use Radix UI for complex components (built into shadcn)
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"

function AccessibleDropdown() {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="outline">Menu</Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent>
        {/* Radix handles all keyboard navigation */}
        <DropdownMenuItem onSelect={() => handleSelect('a')}>
          Option A
        </DropdownMenuItem>
        <DropdownMenuItem onSelect={() => handleSelect('b')}>
          Option B
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
```

**Focus management for modals:**

```typescript
import { Dialog, DialogContent, DialogTrigger } from "@/components/ui/dialog"

function AccessibleModal() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button>Open</Button>
      </DialogTrigger>
      <DialogContent>
        {/*
          Radix Dialog automatically:
          - Traps focus inside modal
          - Returns focus to trigger on close
          - Closes on Escape key
        */}
        <h2>Modal Title</h2>
        <p>Content here</p>
        <Button>Action</Button>
      </DialogContent>
    </Dialog>
  )
}
```

**Custom keyboard handling:**

```typescript
function ListWithKeyboard({ items, onSelect }) {
  const [focusedIndex, setFocusedIndex] = useState(0)
  const listRef = useRef<HTMLUListElement>(null)

  const handleKeyDown = (e: React.KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault()
        setFocusedIndex((i) => Math.min(i + 1, items.length - 1))
        break
      case 'ArrowUp':
        e.preventDefault()
        setFocusedIndex((i) => Math.max(i - 1, 0))
        break
      case 'Enter':
      case ' ':
        e.preventDefault()
        onSelect(items[focusedIndex])
        break
      case 'Home':
        e.preventDefault()
        setFocusedIndex(0)
        break
      case 'End':
        e.preventDefault()
        setFocusedIndex(items.length - 1)
        break
    }
  }

  return (
    <ul
      ref={listRef}
      role="listbox"
      tabIndex={0}
      onKeyDown={handleKeyDown}
      className="focus-visible:ring-2"
    >
      {items.map((item, index) => (
        <li
          key={item.id}
          role="option"
          aria-selected={focusedIndex === index}
          className={cn(
            focusedIndex === index && "bg-accent"
          )}
        >
          {item.name}
        </li>
      ))}
    </ul>
  )
}
```

Key principles:
- Use semantic HTML elements (button, a, input)
- Add `tabIndex={0}` for custom interactive elements
- Handle Enter and Space for activation
- Handle Escape for dismissal
- Handle Arrow keys for lists/menus
- Show visible focus indicators
- Manage focus for modals/dialogs
