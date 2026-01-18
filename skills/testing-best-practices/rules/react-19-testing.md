---
title: Testing React 19 Features
impact: CRITICAL
impactDescription: Test useActionState, useOptimistic, and use() hook
tags: react-19, useActionState, useOptimistic, use
---

## Testing React 19 Features

### Testing useActionState

```typescript
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'

// Mock the server action
vi.mock('./actions', () => ({
  submitForm: vi.fn(),
}))

import { submitForm } from './actions'
import { ContactForm } from './contact-form'

describe('ContactForm with useActionState', () => {
  it('shows pending state during submission', async () => {
    const user = userEvent.setup()

    // Make action slow to test pending state
    vi.mocked(submitForm).mockImplementation(
      () => new Promise((resolve) => setTimeout(() => resolve({ success: true }), 100))
    )

    render(<ContactForm />)

    await user.type(screen.getByLabelText('Email'), 'test@example.com')
    await user.click(screen.getByRole('button', { name: /submit/i }))

    // Button should show pending state
    expect(screen.getByRole('button')).toHaveTextContent(/submitting/i)
    expect(screen.getByRole('button')).toBeDisabled()

    await waitFor(() => {
      expect(screen.getByRole('button')).toHaveTextContent(/submit/i)
    })
  })

  it('displays error state from action', async () => {
    vi.mocked(submitForm).mockResolvedValue({
      success: false,
      error: 'Invalid email'
    })

    render(<ContactForm />)

    await userEvent.click(screen.getByRole('button'))

    await waitFor(() => {
      expect(screen.getByText('Invalid email')).toBeInTheDocument()
    })
  })
})
```

### Testing useOptimistic

```typescript
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { TodoList } from './todo-list'

describe('TodoList with useOptimistic', () => {
  it('shows optimistic update immediately', async () => {
    const user = userEvent.setup()
    const initialTodos = [{ id: '1', title: 'Existing todo' }]

    render(<TodoList todos={initialTodos} />)

    await user.type(screen.getByPlaceholderText('New todo'), 'New optimistic todo')
    await user.click(screen.getByRole('button', { name: /add/i }))

    // Optimistic update should appear immediately
    expect(screen.getByText('New optimistic todo')).toBeInTheDocument()
  })
})
```

### Testing Components with use()

```typescript
import { render, screen } from '@testing-library/react'
import { Suspense } from 'react'
import { Comments } from './comments'

describe('Comments with use() hook', () => {
  it('renders comments from promise', async () => {
    const commentsPromise = Promise.resolve([
      { id: '1', text: 'Great post!' },
      { id: '2', text: 'Thanks for sharing' },
    ])

    render(
      <Suspense fallback={<div>Loading...</div>}>
        <Comments commentsPromise={commentsPromise} />
      </Suspense>
    )

    // Initially shows loading
    expect(screen.getByText('Loading...')).toBeInTheDocument()

    // Then shows content
    expect(await screen.findByText('Great post!')).toBeInTheDocument()
    expect(screen.getByText('Thanks for sharing')).toBeInTheDocument()
  })
})
```

### Mock Setup for useFormStatus

```typescript
// tests/setup.ts
import { vi } from 'vitest'

// Mock react-dom for useFormStatus
vi.mock('react-dom', async () => {
  const actual = await vi.importActual('react-dom')
  return {
    ...actual,
    useFormStatus: () => ({ pending: false, data: null, method: null, action: null }),
  }
})
```
