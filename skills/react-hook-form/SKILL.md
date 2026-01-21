---
name: react-hook-form
description: React Hook Form for performant form handling with Zod validation. Use when building forms, handling validation, integrating with shadcn/ui, or managing complex form state. Triggers on "form", "useForm", "react-hook-form", "validation", "form handling", "zodResolver".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
  context7: react-hook-form/react-hook-form
---

# React Hook Form

Performant form handling with minimal re-renders and Zod validation.

## Installation

```bash
npm install react-hook-form zod @hookform/resolvers
```

---

## Basic Usage

```tsx
'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
})

type FormData = z.infer<typeof schema>

export function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  })

  async function onSubmit(data: FormData) {
    await signIn(data.email, data.password)
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <input type="email" {...register('email')} />
        {errors.email && <span>{errors.email.message}</span>}
      </div>
      <div>
        <input type="password" {...register('password')} />
        {errors.password && <span>{errors.password.message}</span>}
      </div>
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Signing in...' : 'Sign In'}
      </button>
    </form>
  )
}
```

---

## With shadcn/ui Form

```tsx
'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'

const formSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  role: z.enum(['user', 'admin', 'moderator']),
  bio: z.string().max(500).optional(),
})

type FormValues = z.infer<typeof formSchema>

export function ProfileForm() {
  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: '',
      email: '',
      role: 'user',
      bio: '',
    },
  })

  async function onSubmit(values: FormValues) {
    const response = await fetch('/api/profile', {
      method: 'POST',
      body: JSON.stringify(values),
    })
    // Handle response
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input placeholder="John Doe" {...field} />
              </FormControl>
              <FormDescription>Your public display name.</FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input type="email" placeholder="john@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="role"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Role</FormLabel>
              <Select onValueChange={field.onChange} defaultValue={field.value}>
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Select a role" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectItem value="user">User</SelectItem>
                  <SelectItem value="admin">Admin</SelectItem>
                  <SelectItem value="moderator">Moderator</SelectItem>
                </SelectContent>
              </Select>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="bio"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Bio</FormLabel>
              <FormControl>
                <Textarea placeholder="Tell us about yourself" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? 'Saving...' : 'Save Profile'}
        </Button>
      </form>
    </Form>
  )
}
```

---

## Server Actions Integration

```tsx
'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useTransition } from 'react'
import { createPost } from '@/actions/posts'

const schema = z.object({
  title: z.string().min(1, 'Title is required'),
  content: z.string().min(10, 'Content must be at least 10 characters'),
})

export function CreatePostForm() {
  const [isPending, startTransition] = useTransition()
  const form = useForm<z.infer<typeof schema>>({
    resolver: zodResolver(schema),
  })

  function onSubmit(data: z.infer<typeof schema>) {
    startTransition(async () => {
      const result = await createPost(data)
      if (result.error) {
        form.setError('root', { message: result.error })
      }
    })
  }

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      {form.formState.errors.root && (
        <div className="text-red-500">{form.formState.errors.root.message}</div>
      )}
      {/* Form fields */}
      <button disabled={isPending}>
        {isPending ? 'Creating...' : 'Create Post'}
      </button>
    </form>
  )
}
```

---

## Dynamic Fields (Arrays)

```tsx
'use client'

import { useForm, useFieldArray } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  emails: z.array(z.object({
    value: z.string().email(),
  })).min(1, 'At least one email required'),
})

export function MultiEmailForm() {
  const form = useForm<z.infer<typeof schema>>({
    resolver: zodResolver(schema),
    defaultValues: {
      emails: [{ value: '' }],
    },
  })

  const { fields, append, remove } = useFieldArray({
    control: form.control,
    name: 'emails',
  })

  return (
    <form onSubmit={form.handleSubmit(console.log)}>
      {fields.map((field, index) => (
        <div key={field.id} className="flex gap-2">
          <input {...form.register(`emails.${index}.value`)} />
          {fields.length > 1 && (
            <button type="button" onClick={() => remove(index)}>
              Remove
            </button>
          )}
        </div>
      ))}
      <button type="button" onClick={() => append({ value: '' })}>
        Add Email
      </button>
      <button type="submit">Submit</button>
    </form>
  )
}
```

---

## Conditional Validation

```tsx
const schema = z.object({
  accountType: z.enum(['personal', 'business']),
  companyName: z.string().optional(),
  taxId: z.string().optional(),
}).refine((data) => {
  if (data.accountType === 'business') {
    return data.companyName && data.companyName.length > 0
  }
  return true
}, {
  message: 'Company name is required for business accounts',
  path: ['companyName'],
}).refine((data) => {
  if (data.accountType === 'business') {
    return data.taxId && data.taxId.length > 0
  }
  return true
}, {
  message: 'Tax ID is required for business accounts',
  path: ['taxId'],
})
```

---

## Watch & Dependent Fields

```tsx
export function DependentFieldsForm() {
  const form = useForm()
  const accountType = form.watch('accountType')

  return (
    <form>
      <select {...form.register('accountType')}>
        <option value="personal">Personal</option>
        <option value="business">Business</option>
      </select>

      {accountType === 'business' && (
        <>
          <input {...form.register('companyName')} placeholder="Company Name" />
          <input {...form.register('taxId')} placeholder="Tax ID" />
        </>
      )}
    </form>
  )
}
```

---

## Form State Helpers

```tsx
const {
  formState: {
    errors,           // Validation errors
    isSubmitting,     // Submit in progress
    isSubmitted,      // Form has been submitted
    isValid,          // Form is valid
    isDirty,          // Form has been modified
    dirtyFields,      // Which fields were modified
    touchedFields,    // Which fields were touched
  },
  reset,              // Reset form to defaults
  setValue,           // Set field value programmatically
  getValues,          // Get all form values
  trigger,            // Trigger validation
  setError,           // Set custom error
  clearErrors,        // Clear errors
} = useForm()

// Reset to new values
reset({ name: 'New Value', email: 'new@example.com' })

// Set single field
setValue('name', 'John', { shouldValidate: true })

// Trigger validation
await trigger('email') // Validate single field
await trigger()        // Validate all fields

// Set custom error
setError('email', { type: 'custom', message: 'Email already exists' })
```

---

## File Upload

```tsx
const schema = z.object({
  avatar: z.instanceof(FileList).refine((files) => files.length > 0, 'Required'),
})

export function FileUploadForm() {
  const form = useForm<z.infer<typeof schema>>({
    resolver: zodResolver(schema),
  })

  async function onSubmit(data: z.infer<typeof schema>) {
    const formData = new FormData()
    formData.append('avatar', data.avatar[0])
    await fetch('/api/upload', { method: 'POST', body: formData })
  }

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <input type="file" accept="image/*" {...form.register('avatar')} />
      {form.formState.errors.avatar && (
        <span>{form.formState.errors.avatar.message}</span>
      )}
      <button type="submit">Upload</button>
    </form>
  )
}
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Re-rendering entire form | Use `Controller` for controlled components |
| Not using `key` in field arrays | Use `field.id` from `useFieldArray` |
| Missing `resolver` | Add `zodResolver(schema)` |
| Setting values without validation | Use `setValue(..., { shouldValidate: true })` |
| Not handling async errors | Use `setError` for server errors |

---

## Quick Reference

| Hook | Purpose |
|------|---------|
| `useForm` | Main form hook |
| `useFieldArray` | Dynamic field arrays |
| `useWatch` | Subscribe to field changes |
| `useFormContext` | Access form in nested components |
| `useController` | Controlled component wrapper |

| Method | Purpose |
|--------|---------|
| `register` | Register input |
| `handleSubmit` | Handle form submission |
| `setValue` | Set field value |
| `getValues` | Get all values |
| `reset` | Reset form |
| `trigger` | Trigger validation |
| `setError` | Set custom error |

## References

- [React Hook Form Docs](https://react-hook-form.com)
- [Zod Resolver](https://github.com/react-hook-form/resolvers)
- [shadcn/ui Form](https://ui.shadcn.com/docs/components/form)
