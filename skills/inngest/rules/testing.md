# Testing

Test Inngest functions locally and in CI.

## Unit Testing

```typescript
import { createStepTools } from 'inngest/test'
import { processOrder } from './functions'

describe('processOrder', () => {
  it('processes order successfully', async () => {
    const { result } = await processOrder.invoke({
      events: [
        {
          name: 'order/created',
          data: { orderId: '123', userId: 'user-1', total: 100 },
        },
      ],
    })

    expect(result.success).toBe(true)
  })

  it('handles payment failure', async () => {
    // Mock step.run to simulate failure
    const { result, error } = await processOrder.invoke({
      events: [
        {
          name: 'order/created',
          data: { orderId: '456', userId: 'user-1', total: 100 },
        },
      ],
      ctx: {
        // Provide mocks for steps
        step: {
          run: async (name, fn) => {
            if (name === 'charge-payment') {
              throw new Error('Payment declined')
            }
            return fn()
          },
        },
      },
    })

    expect(error?.message).toBe('Payment declined')
  })
})
```

## Dev Server

Run Inngest locally:

```bash
# Start dev server
npx inngest-cli@latest dev

# Or with specific port
npx inngest-cli@latest dev -u http://localhost:3000/api/inngest
```

## Trigger Test Events

```bash
# Send test event via CLI
npx inngest-cli@latest send '{
  "name": "test/hello.world",
  "data": { "email": "test@example.com" }
}'
```

## Environment Variables

```bash
# .env.local
INNGEST_EVENT_KEY=your-event-key
INNGEST_SIGNING_KEY=your-signing-key

# For local development
INNGEST_DEV=1
```

## Error Handling Tests

```typescript
import { NonRetriableError } from 'inngest'

export const validateUser = inngest.createFunction(
  { id: 'validate-user' },
  { event: 'user/validate' },
  async ({ event }) => {
    const user = await getUser(event.data.userId)

    if (!user) {
      // This error won't trigger retries
      throw new NonRetriableError('User not found')
    }

    return { valid: true }
  }
)

// Test
it('throws non-retriable error for missing user', async () => {
  const { error } = await validateUser.invoke({
    events: [{ name: 'user/validate', data: { userId: 'nonexistent' } }],
  })

  expect(error).toBeInstanceOf(NonRetriableError)
})
```

## Integration Testing

```typescript
import { inngest } from './client'

describe('Integration', () => {
  it('sends event and function executes', async () => {
    // Send real event to dev server
    await inngest.send({
      name: 'test/integration',
      data: { testId: 'abc123' },
    })

    // Wait for function to complete
    // Check side effects (DB, API calls, etc.)
  })
})
```
