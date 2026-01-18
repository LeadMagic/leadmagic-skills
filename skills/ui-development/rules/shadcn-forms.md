---
title: Forms with React Hook Form and Zod
impact: HIGH
impactDescription: Type-safe forms with validation
tags: forms, validation, react-hook-form, zod
---

## Forms with React Hook Form and Zod

shadcn/ui integrates with React Hook Form and Zod for type-safe, validated forms.

**Installation:**

```bash
npm install react-hook-form @hookform/resolvers zod

# Add shadcn form components
npx shadcn@latest add form input label
```

**Basic Form Setup:**

```typescript
'use client'

import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'
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

// 1. Define schema
const formSchema = z.object({
  username: z.string()
    .min(2, 'Username must be at least 2 characters')
    .max(50, 'Username must be less than 50 characters'),
  email: z.string()
    .email('Invalid email address'),
})

// 2. Infer type from schema
type FormValues = z.infer<typeof formSchema>

// 3. Create form component
export function ProfileForm() {
  // 4. Initialize form with resolver
  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      username: '',
      email: '',
    },
  })

  // 5. Handle submit
  function onSubmit(values: FormValues) {
    console.log(values)
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        <FormField
          control={form.control}
          name="username"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Username</FormLabel>
              <FormControl>
                <Input placeholder="johndoe" {...field} />
              </FormControl>
              <FormDescription>
                This is your public display name.
              </FormDescription>
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

        <Button type="submit">Submit</Button>
      </form>
    </Form>
  )
}
```

**Form with Select:**

```typescript
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'

const schema = z.object({
  role: z.enum(['admin', 'user', 'viewer'], {
    required_error: 'Please select a role',
  }),
})

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
          <SelectItem value="admin">Admin</SelectItem>
          <SelectItem value="user">User</SelectItem>
          <SelectItem value="viewer">Viewer</SelectItem>
        </SelectContent>
      </Select>
      <FormMessage />
    </FormItem>
  )}
/>
```

**Form with Checkbox:**

```typescript
import { Checkbox } from '@/components/ui/checkbox'

const schema = z.object({
  terms: z.boolean().refine(val => val === true, {
    message: 'You must accept the terms',
  }),
})

<FormField
  control={form.control}
  name="terms"
  render={({ field }) => (
    <FormItem className="flex flex-row items-start space-x-3 space-y-0">
      <FormControl>
        <Checkbox
          checked={field.value}
          onCheckedChange={field.onChange}
        />
      </FormControl>
      <div className="space-y-1 leading-none">
        <FormLabel>Accept terms and conditions</FormLabel>
        <FormDescription>
          You agree to our Terms of Service and Privacy Policy.
        </FormDescription>
      </div>
      <FormMessage />
    </FormItem>
  )}
/>
```

**Form with Textarea:**

```typescript
import { Textarea } from '@/components/ui/textarea'

const schema = z.object({
  bio: z.string()
    .min(10, 'Bio must be at least 10 characters')
    .max(500, 'Bio must be less than 500 characters'),
})

<FormField
  control={form.control}
  name="bio"
  render={({ field }) => (
    <FormItem>
      <FormLabel>Bio</FormLabel>
      <FormControl>
        <Textarea
          placeholder="Tell us about yourself..."
          className="resize-none"
          {...field}
        />
      </FormControl>
      <FormDescription>
        {field.value?.length || 0}/500 characters
      </FormDescription>
      <FormMessage />
    </FormItem>
  )}
/>
```

**Form with Date Picker:**

```typescript
import { format } from 'date-fns'
import { CalendarIcon } from 'lucide-react'
import { Calendar } from '@/components/ui/calendar'
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover'

const schema = z.object({
  dob: z.date({
    required_error: 'Please select a date',
  }),
})

<FormField
  control={form.control}
  name="dob"
  render={({ field }) => (
    <FormItem className="flex flex-col">
      <FormLabel>Date of birth</FormLabel>
      <Popover>
        <PopoverTrigger asChild>
          <FormControl>
            <Button
              variant="outline"
              className={cn(
                'w-[240px] pl-3 text-left font-normal',
                !field.value && 'text-muted-foreground'
              )}
            >
              {field.value ? (
                format(field.value, 'PPP')
              ) : (
                <span>Pick a date</span>
              )}
              <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
            </Button>
          </FormControl>
        </PopoverTrigger>
        <PopoverContent className="w-auto p-0" align="start">
          <Calendar
            mode="single"
            selected={field.value}
            onSelect={field.onChange}
            disabled={(date) =>
              date > new Date() || date < new Date('1900-01-01')
            }
          />
        </PopoverContent>
      </Popover>
      <FormMessage />
    </FormItem>
  )}
/>
```

**Loading State:**

```typescript
import { Loader2 } from 'lucide-react'

export function ProfileForm() {
  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
  })

  const { isSubmitting } = form.formState

  async function onSubmit(values: FormValues) {
    await saveProfile(values)
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        {/* fields */}

        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
          {isSubmitting ? 'Saving...' : 'Save'}
        </Button>
      </form>
    </Form>
  )
}
```

**Complex Schema Example:**

```typescript
const signupSchema = z.object({
  email: z.string().email(),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain an uppercase letter')
    .regex(/[0-9]/, 'Password must contain a number'),
  confirmPassword: z.string(),
  profile: z.object({
    firstName: z.string().min(1, 'First name is required'),
    lastName: z.string().min(1, 'Last name is required'),
    age: z.coerce.number().min(18, 'Must be at least 18'),
  }),
  notifications: z.array(z.enum(['email', 'sms', 'push'])),
}).refine(data => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
})
```
