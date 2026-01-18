---
title: Icons with Lucide React
impact: MEDIUM
impactDescription: Consistent icon usage across components
tags: icons, lucide, components
---

## Icons with Lucide React

shadcn/ui uses Lucide React for icons. It provides 1000+ icons with consistent styling.

**Installation:**

```bash
npm install lucide-react
```

**Basic Usage:**

```typescript
import { Search, Menu, X, ChevronDown, Check } from 'lucide-react'

function SearchBar() {
  return (
    <div className="relative">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
      <input className="pl-10 ..." placeholder="Search..." />
    </div>
  )
}
```

**Icon Props:**

```typescript
import { Home } from 'lucide-react'

// Size - defaults to 24x24
<Home size={16} />
<Home className="h-4 w-4" />  // Tailwind approach
<Home className="size-4" />   // Tailwind v4 shorthand

// Color - inherits currentColor by default
<Home className="text-primary" />
<Home stroke="red" />

// Stroke width - defaults to 2
<Home strokeWidth={1.5} />

// Absolutely positioned
<Home className="absolute right-2 top-2" />
```

**Common Icons in shadcn/ui:**

```typescript
// Navigation
import {
  Menu, X, ChevronDown, ChevronUp, ChevronLeft, ChevronRight,
  ArrowLeft, ArrowRight, ArrowUp, ArrowDown,
  Home, Settings, User, LogOut, LogIn
} from 'lucide-react'

// Actions
import {
  Plus, Minus, Edit, Trash2, Copy, Download, Upload,
  Share, Send, Save, Undo, Redo, RefreshCw
} from 'lucide-react'

// Status
import {
  Check, X, AlertCircle, AlertTriangle, Info, HelpCircle,
  CheckCircle, XCircle, Loader2
} from 'lucide-react'

// Media
import {
  Image, FileText, File, Folder, Video, Music,
  Camera, Mic, Play, Pause, Volume2, VolumeX
} from 'lucide-react'

// Communication
import {
  Mail, MessageSquare, Phone, Bell, Calendar,
  Clock, Search, Filter, SortAsc, SortDesc
} from 'lucide-react'

// UI elements
import {
  Sun, Moon, Monitor, Eye, EyeOff, Lock, Unlock,
  Star, Heart, Bookmark, Flag, Tag
} from 'lucide-react'
```

**Icon Button Pattern:**

```typescript
import { Button } from '@/components/ui/button'
import { Menu, X } from 'lucide-react'

// Icon-only button
<Button variant="ghost" size="icon">
  <Menu className="h-4 w-4" />
  <span className="sr-only">Toggle menu</span>
</Button>

// Icon with text
<Button>
  <Plus className="mr-2 h-4 w-4" />
  Add Item
</Button>

// Icon after text
<Button>
  Continue
  <ArrowRight className="ml-2 h-4 w-4" />
</Button>
```

**Loading Spinner:**

```typescript
import { Loader2 } from 'lucide-react'

// Spinning loader
<Loader2 className="h-4 w-4 animate-spin" />

// In button
<Button disabled>
  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
  Please wait
</Button>
```

**Icon in Input:**

```typescript
import { Search, X } from 'lucide-react'
import { Input } from '@/components/ui/input'

function SearchInput({ value, onChange, onClear }) {
  return (
    <div className="relative">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
      <Input
        value={value}
        onChange={onChange}
        className="pl-10 pr-10"
        placeholder="Search..."
      />
      {value && (
        <button
          onClick={onClear}
          className="absolute right-3 top-1/2 -translate-y-1/2"
        >
          <X className="h-4 w-4 text-muted-foreground hover:text-foreground" />
        </button>
      )}
    </div>
  )
}
```

**Custom Icon Wrapper:**

```typescript
import { LucideIcon } from 'lucide-react'
import { cn } from '@/lib/utils'

interface IconProps {
  icon: LucideIcon
  className?: string
  size?: 'sm' | 'md' | 'lg'
}

const sizeMap = {
  sm: 'h-4 w-4',
  md: 'h-5 w-5',
  lg: 'h-6 w-6',
}

export function Icon({ icon: IconComponent, className, size = 'md' }: IconProps) {
  return <IconComponent className={cn(sizeMap[size], className)} />
}

// Usage
import { Settings } from 'lucide-react'
<Icon icon={Settings} size="lg" className="text-primary" />
```

**Dynamic Icons:**

```typescript
import * as Icons from 'lucide-react'
import { LucideIcon } from 'lucide-react'

// Get icon by name
function DynamicIcon({ name, ...props }: { name: string } & React.ComponentProps<LucideIcon>) {
  const IconComponent = Icons[name as keyof typeof Icons] as LucideIcon

  if (!IconComponent) {
    return <Icons.HelpCircle {...props} />
  }

  return <IconComponent {...props} />
}

// Usage
<DynamicIcon name="Settings" className="h-4 w-4" />
<DynamicIcon name="User" className="h-4 w-4" />
```

**Bundle Size Optimization:**

```typescript
// ✓ Good: Import specific icons (tree-shakeable)
import { Search, Menu, X } from 'lucide-react'

// ✗ Bad: Import entire library
import * as Icons from 'lucide-react'

// ✗ Bad: Dynamic import of all icons in client bundle
const Icon = Icons[iconName]
```

**Icon Resources:**

- Browse all icons: https://lucide.dev/icons
- Search by category, style, or keyword
- Copy import statement directly
