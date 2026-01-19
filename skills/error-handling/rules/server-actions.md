---
title: Server Action Error Handling
impact: HIGH
impactDescription: Handle errors in Server Actions with useActionState
tags: server-actions, react-19, useActionState, forms
---

## Server Action Error Handling

### Action with Result Type

```typescript
// app/actions.ts
'use server'

import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  message: z.string().min(10),
})

type ActionResult =
  | { success: true; data: { id: string } }
  | { success: false; error: string; fieldErrors?: Record<string, string[]> }

export async function submitForm(
  prevState: ActionResult | null,
  formData: FormData
): Promise<ActionResult> {
  try {
    const result = schema.safeParse({
      email: formData.get('email'),
      message: formData.get('message'),
    })

    if (!result.success) {
      return {
        success: false,
        error: 'Validation failed',
        fieldErrors: result.error.flatten().fieldErrors,
      }
    }

    const submission = await db.insert(submissions).values(result.data).returning()

    return { success: true, data: { id: submission[0].id } }
  } catch (e) {
    console.error('submitForm error:', e)
    return { success: false, error: 'Failed to submit form. Please try again.' }
  }
}
```

### Client Component with useActionState

```typescript
'use client'

import { useActionState } from 'react'
import { submitForm } from './actions'

export function ContactForm() {
  const [state, formAction, pending] = useActionState(submitForm, null)

  return (
    <form action={formAction}>
      <div>
        <label htmlFor="email">Email</label>
        <input id="email" name="email" type="email" required />
        {state?.fieldErrors?.email && (
          <p className="text-sm text-red-500">{state.fieldErrors.email[0]}</p>
        )}
      </div>

      <div>
        <label htmlFor="message">Message</label>
        <textarea id="message" name="message" required />
        {state?.fieldErrors?.message && (
          <p className="text-sm text-red-500">{state.fieldErrors.message[0]}</p>
        )}
      </div>

      {state?.error && !state.fieldErrors && (
        <div className="p-3 bg-red-50 text-red-700 rounded">
          {state.error}
        </div>
      )}

      {state?.success && (
        <div className="p-3 bg-green-50 text-green-700 rounded">
          Form submitted successfully!
        </div>
      )}

      <button type="submit" disabled={pending}>
        {pending ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  )
}
```

### Key Patterns

1. **Return result objects** - Don't throw from Server Actions
2. **Include field-level errors** - Better UX than generic messages
3. **Use prevState parameter** - Required by useActionState
4. **Log server-side** - Keep detailed logs but return friendly messages
5. **Handle pending state** - Disable buttons, show spinners

### Common Mistakes

```typescript
// ❌ WRONG: Missing prevState parameter
export async function createPost(formData: FormData) {
  'use server'
  // ...
}

// ✅ CORRECT: prevState is required
export async function createPost(
  prevState: any,
  formData: FormData
) {
  'use server'
  // ...
}
```
