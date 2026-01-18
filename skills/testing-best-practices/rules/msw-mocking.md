---
title: API Mocking with MSW
impact: HIGH
impactDescription: Realistic API mocking for integration tests
tags: msw, api, mocking, integration
---

## API Mocking with MSW

### Setup

```typescript
// tests/mocks/handlers.ts
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com',
    })
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json({ id: '123', ...body }, { status: 201 })
  }),

  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: '1', name: 'John' },
      { id: '2', name: 'Jane' },
    ])
  }),
]

// tests/mocks/server.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)
```

### Integration in Setup

```typescript
// tests/setup.ts
import { server } from './mocks/server'
import { beforeAll, afterEach, afterAll } from 'vitest'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

### Per-Test Handler Override

```typescript
import { server } from '@/tests/mocks/server'
import { http, HttpResponse } from 'msw'

it('handles error state', async () => {
  server.use(
    http.get('/api/users/:id', () => {
      return HttpResponse.json(
        { error: 'User not found' },
        { status: 404 }
      )
    })
  )

  render(<UserProfile userId="999" />)

  await waitFor(() => {
    expect(screen.getByRole('alert')).toHaveTextContent(/not found/i)
  })
})
```

### Why MSW over fetch mocking

```typescript
// ❌ WRONG - mocking fetch directly is brittle
vi.spyOn(global, 'fetch').mockResolvedValue({
  json: () => Promise.resolve({ data: 'test' }),
})

// ✅ CORRECT - MSW intercepts at network level
const server = setupServer(
  http.get('/api/users', () => {
    return HttpResponse.json([{ id: 1, name: 'John' }])
  })
)
```
