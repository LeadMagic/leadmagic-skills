---
title: Toast Notifications with Sonner
impact: MEDIUM
impactDescription: Modern toast notifications
tags: toast, notifications, sonner
---

## Toast Notifications with Sonner

The legacy `toast` component is deprecated. Use Sonner for toast notifications.

**Installation:**

```bash
npm install sonner

# Or add via shadcn (includes Sonner wrapper)
npx shadcn@latest add sonner
```

**Setup in Layout:**

```typescript
// app/layout.tsx
import { Toaster } from 'sonner'
// Or from shadcn wrapper:
// import { Toaster } from '@/components/ui/sonner'

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

**Basic Usage:**

```typescript
import { toast } from 'sonner'

// Simple notifications
toast('Event has been created')
toast.success('Successfully saved!')
toast.error('Something went wrong')
toast.warning('Please review your input')
toast.info('New update available')

// With description
toast.success('Profile updated', {
  description: 'Your changes have been saved.',
})

// With action
toast('File uploaded', {
  action: {
    label: 'View',
    onClick: () => router.push('/files'),
  },
})
```

**Promise Toast:**

```typescript
// Automatic loading, success, error states
toast.promise(saveChanges(), {
  loading: 'Saving changes...',
  success: 'Changes saved!',
  error: 'Failed to save changes',
})

// With data in success message
toast.promise(fetchUser(id), {
  loading: 'Loading user...',
  success: (data) => `Welcome back, ${data.name}!`,
  error: (err) => err.message,
})
```

**Custom Toast:**

```typescript
// Custom JSX content
toast.custom((id) => (
  <div className="flex items-center gap-4 p-4 bg-card border rounded-lg shadow-lg">
    <Avatar>
      <AvatarImage src={user.avatar} />
    </Avatar>
    <div>
      <p className="font-medium">{user.name}</p>
      <p className="text-sm text-muted-foreground">sent you a message</p>
    </div>
    <Button size="sm" onClick={() => toast.dismiss(id)}>
      View
    </Button>
  </div>
))
```

**Toast Options:**

```typescript
toast.success('Saved!', {
  // Duration in milliseconds (default: 4000)
  duration: 5000,

  // Position
  position: 'top-right', // top-left, top-center, top-right, bottom-left, bottom-center, bottom-right

  // Styling
  className: 'my-toast',
  style: { background: 'red' },

  // Callbacks
  onDismiss: () => console.log('Toast dismissed'),
  onAutoClose: () => console.log('Auto closed'),

  // Prevent auto-close
  duration: Infinity,

  // Custom icon
  icon: <CheckCircle className="h-4 w-4" />,

  // Dismissible
  dismissible: true,
})
```

**Toaster Configuration:**

```typescript
<Toaster
  position="top-right"
  expand={false}
  richColors
  closeButton
  theme="system" // light, dark, system
  toastOptions={{
    className: 'my-toast',
    duration: 4000,
  }}
/>
```

**shadcn Sonner Wrapper:**

```typescript
// components/ui/sonner.tsx
'use client'

import { useTheme } from 'next-themes'
import { Toaster as Sonner } from 'sonner'

type ToasterProps = React.ComponentProps<typeof Sonner>

const Toaster = ({ ...props }: ToasterProps) => {
  const { theme = 'system' } = useTheme()

  return (
    <Sonner
      theme={theme as ToasterProps['theme']}
      className="toaster group"
      toastOptions={{
        classNames: {
          toast:
            'group toast group-[.toaster]:bg-background group-[.toaster]:text-foreground group-[.toaster]:border-border group-[.toaster]:shadow-lg',
          description: 'group-[.toast]:text-muted-foreground',
          actionButton:
            'group-[.toast]:bg-primary group-[.toast]:text-primary-foreground',
          cancelButton:
            'group-[.toast]:bg-muted group-[.toast]:text-muted-foreground',
        },
      }}
      {...props}
    />
  )
}

export { Toaster }
```

**Migration from Legacy Toast:**

```typescript
// ❌ Old (deprecated)
import { useToast } from '@/components/ui/use-toast'

const { toast } = useToast()
toast({
  title: 'Success',
  description: 'Your changes have been saved.',
})

// ✅ New (Sonner)
import { toast } from 'sonner'

toast.success('Success', {
  description: 'Your changes have been saved.',
})
```

**Common Patterns:**

```typescript
// Form submission
async function onSubmit(data: FormData) {
  toast.promise(submitForm(data), {
    loading: 'Submitting...',
    success: 'Form submitted successfully!',
    error: 'Failed to submit form',
  })
}

// Copy to clipboard
function copyToClipboard(text: string) {
  navigator.clipboard.writeText(text)
  toast.success('Copied to clipboard')
}

// Delete with undo
function deleteItem(id: string) {
  const item = items.find(i => i.id === id)
  setItems(items.filter(i => i.id !== id))

  toast('Item deleted', {
    action: {
      label: 'Undo',
      onClick: () => setItems(prev => [...prev, item]),
    },
  })
}

// Error handling
async function fetchData() {
  try {
    const data = await api.getData()
    return data
  } catch (error) {
    toast.error('Failed to load data', {
      description: error.message,
      action: {
        label: 'Retry',
        onClick: () => fetchData(),
      },
    })
  }
}
```
