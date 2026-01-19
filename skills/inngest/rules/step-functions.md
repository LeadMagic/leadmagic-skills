# Step Functions

All step.* methods for durable workflow execution.

## step.run - Durable Execution

Each step.run is durable - if function fails, it resumes from last completed step:

```typescript
const result = await step.run('step-name', async () => {
  // This code runs exactly once, even if function retries
  return await expensiveOperation()
})
```

## step.sleep - Durable Delays

```typescript
// Sleep for a duration - survives function restarts
await step.sleep('wait-1-hour', '1h')

// Sleep until a specific time
await step.sleepUntil('wait-until-tomorrow', tomorrow)
```

## step.waitForEvent - Wait for External Events

```typescript
const paymentEvent = await step.waitForEvent('wait-for-payment', {
  event: 'payment/completed',
  match: 'data.orderId', // Match on orderId
  timeout: '24h',
})

if (!paymentEvent) {
  // Timeout - payment not received
  await step.run('cancel-order', async () => {
    await cancelOrder(orderId)
  })
  return { status: 'cancelled' }
}

// Payment received - continue
await step.run('fulfill-order', async () => {
  await fulfillOrder(orderId)
})
```

## step.invoke - Call Other Functions

```typescript
import { referenceFunction } from 'inngest'

// Reference function without importing dependencies
const computePi = referenceFunction({
  functionId: 'compute-pi',
})

// Cross-app reference
const computeSquare = referenceFunction({
  appId: 'my-python-app',
  functionId: 'compute-square',
})

const result = await step.invoke('call-processor', {
  function: computePi,
  data: { precision: 100 },
})
```

## step.fetch - Durable HTTP (SDK v3.0+)

Make HTTP requests that survive function restarts:

```typescript
import { fetch } from 'inngest'

// In your function
const response = await step.fetch('call-api', {
  url: 'https://api.example.com/data',
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ key: 'value' }),
})

const data = await response.json()
```

## Parallel Steps

```typescript
const chunks = splitTextIntoChunks(event.data.text)

const summaries = await Promise.all(
  chunks.map((chunk, index) =>
    step.run(`summarize-chunk-${index}`, () => summarizeChunk(chunk))
  )
)

await step.run('aggregate', async () => {
  return await aggregateSummaries(summaries)
})
```

## Important Notes

- **Side effects MUST be in step.run** - Code outside steps may run multiple times
- **Steps are memoized** - Same step name returns cached result on retry
- **Step names must be unique** - Use dynamic names for loops (`step-${i}`)
