---
name: testing-best-practices
description: Testing patterns for React 19, Next.js 16, and Cloudflare Workers. Use when writing tests, setting up test infrastructure, or implementing testing strategies. Covers Vitest, Testing Library, Playwright, and MSW.
license: MIT
metadata:
  author: leadmagic
  version: "2.0.0"
---

# Testing Best Practices

Testing patterns for React 19, Next.js 16, and Cloudflare Workers.

## What's New in Vitest 3.2

- **`projects` replaces `workspace`** - Use `projects` in vitest.config.ts
- **Browser Mode** - Better Playwright integration
- **`vi.mock({ spy: true })`** - Spy without replacing

## Stack

```bash
# Unit & Integration
npm install -D vitest @vitejs/plugin-react @testing-library/react @testing-library/jest-dom @testing-library/user-event

# E2E
npm install -D @playwright/test

# API Mocking
npm install -D msw

# Workers Testing
npm install -D @cloudflare/vitest-pool-workers
```

---

## Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./tests/setup.ts'],
    include: ['**/*.test.{ts,tsx}'],
  },
})
```

```typescript
// tests/setup.ts
import '@testing-library/jest-dom/vitest'
import { cleanup } from '@testing-library/react'
import { afterEach, vi } from 'vitest'

afterEach(() => cleanup())

// Mock Next.js router
vi.mock('next/navigation', () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  useSearchParams: () => new URLSearchParams(),
  usePathname: () => '/',
}))
```

---

## Component Testing

```typescript
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'

describe('Button', () => {
  it('renders and handles click', async () => {
    const user = userEvent.setup()
    const handleClick = vi.fn()

    render(<Button onClick={handleClick}>Click me</Button>)
    await user.click(screen.getByRole('button'))

    expect(handleClick).toHaveBeenCalledOnce()
  })
})
```

### With Providers

```typescript
// tests/utils.tsx
import { render, RenderOptions } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

function AllProviders({ children }: { children: React.ReactNode }) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
}

export function renderWithProviders(ui: ReactElement, options?: Omit<RenderOptions, 'wrapper'>) {
  return render(ui, { wrapper: AllProviders, ...options })
}
```

### Async Testing

```typescript
import { render, screen, waitFor } from '@testing-library/react'

it('loads data', async () => {
  render(<UserProfile userId="123" />)
  
  expect(screen.getByRole('status')).toHaveTextContent(/loading/i)
  
  await waitFor(() => {
    expect(screen.getByRole('heading')).toHaveTextContent('John Doe')
  })
})
```

---

## API Mocking with MSW

See `rules/msw-mocking.md` for detailed patterns.

```typescript
// tests/mocks/handlers.ts
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'John' })
  }),
]

// tests/mocks/server.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'
export const server = setupServer(...handlers)

// tests/setup.ts
beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

---

## Playwright E2E

See `rules/playwright-e2e.md` for detailed patterns.

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test'

test('user can sign in', async ({ page }) => {
  await page.goto('/login')
  await page.getByLabel('Email').fill('user@example.com')
  await page.getByLabel('Password').fill('password123')
  await page.getByRole('button', { name: /sign in/i }).click()
  await expect(page).toHaveURL('/dashboard')
})
```

---

## Testing React 19

See `rules/react-19-testing.md` for detailed patterns.

```typescript
// Testing useActionState
vi.mock('./actions', () => ({ submitForm: vi.fn() }))

it('shows pending state', async () => {
  vi.mocked(submitForm).mockImplementation(
    () => new Promise(r => setTimeout(() => r({ success: true }), 100))
  )
  render(<ContactForm />)
  await userEvent.click(screen.getByRole('button'))
  expect(screen.getByRole('button')).toBeDisabled()
})
```

---

## Cloudflare Workers

```typescript
import { env, createExecutionContext, waitOnExecutionContext } from 'cloudflare:test'
import worker from './index'

it('responds correctly', async () => {
  const request = new Request('http://example.com/')
  const ctx = createExecutionContext()
  const response = await worker.fetch(request, env, ctx)
  await waitOnExecutionContext(ctx)
  expect(response.status).toBe(200)
})
```

---

## Testing Pyramid

```
       /\
      /E2E\        <- Few, critical paths
     /------\
    /Integration\ <- API + Components
   /--------------\
  /  Unit Tests   \  <- Many, fast
 /------------------\
```

| Level | What | Tools |
|-------|------|-------|
| Unit | Pure functions | Vitest |
| Component | UI isolation | Testing Library |
| Integration | Components + API | Testing Library + MSW |
| E2E | Full flows | Playwright |

---

## Query Priority

```typescript
// 1. Accessible (preferred)
screen.getByRole('button', { name: /submit/i })
screen.getByLabelText('Email')
screen.getByText('Welcome')

// 2. Semantic
screen.getByAltText('Profile')

// 3. Test ID (last resort)
screen.getByTestId('custom')
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Mock fetch directly | Use MSW |
| Test implementation | Test behavior |
| No async cleanup | Add `afterEach(() => cleanup())` |
| Race conditions | Use `waitFor()` |
| getByTestId first | Use accessible queries |

---

## Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test"
  }
}
```
