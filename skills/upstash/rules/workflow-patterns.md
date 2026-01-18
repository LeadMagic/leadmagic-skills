---
title: Upstash Workflow Patterns
impact: HIGH
impactDescription: Durable execution and orchestration
tags: workflow, upstash, orchestration
---

## Upstash Workflow Patterns

### Basic Workflow

```typescript
import { serve } from "@upstash/workflow/nextjs"

type OrderPayload = {
  orderId: string
  userId: string
  items: { productId: string; quantity: number }[]
}

export const { POST } = serve<OrderPayload>(async (context) => {
  const { orderId, userId, items } = context.requestPayload

  // Step 1: Validate (auto-retries on failure)
  const inventory = await context.run("check-inventory", async () => {
    const stock = await db.inventory.check(items)
    if (!stock.available) throw new Error("Out of stock")
    return stock
  })

  // Step 2: Process payment
  const payment = await context.run("process-payment", async () => {
    return await stripe.charges.create({ amount: inventory.total, currency: "usd" })
  })

  // Step 3: Parallel tasks
  const [email, shipment] = await Promise.all([
    context.run("send-email", () => sendEmail(userId, "Confirmed!")),
    context.run("schedule-shipment", () => logistics.schedule(orderId)),
  ])

  return { orderId, paymentId: payment.id }
})
```

### Wait for Events

```typescript
export const { POST } = serve<{ orderId: string }>(async (context) => {
  const { orderId } = context.requestPayload

  await context.run("initiate-payment", async () => {
    await paymentGateway.createIntent(orderId)
  })

  // Wait up to 24 hours
  const { eventData, timeout } = await context.waitForEvent(
    "wait-for-payment",
    `payment-${orderId}`,
    { timeout: "24h" }
  )

  if (timeout) {
    await context.run("cancel", () => db.orders.update(orderId, { status: "cancelled" }))
    return { success: false }
  }

  await context.run("fulfill", () => db.orders.update(orderId, { status: "paid" }))
  return { success: true }
})
```

### Notify Workflows

```typescript
// From another workflow
const { notifyResponse } = await context.notify(
  "notify-payment",
  `payment-${orderId}`,
  { transactionId: "txn_12345" }
)

// From external service
import { Client } from "@upstash/workflow"
const client = new Client({ token: process.env.QSTASH_TOKEN! })

await client.notify({
  eventId: "payment-ord_123",
  eventData: { transactionId: "txn_xyz" },
})
```

### Sleep & Delays

```typescript
export const { POST } = serve(async (context) => {
  await context.run("step-1", async () => { /* ... */ })

  await context.sleep("wait-10s", 10) // 10 seconds

  await context.sleepUntil("wait-until", new Date("2025-01-20T09:00:00Z"))

  await context.run("step-2", async () => { /* ... */ })
})
```

### Configuration

```typescript
export const { POST } = serve<string>(
  async (context) => { /* ... */ },
  {
    retries: 3,
    baseUrl: "https://myapp.com",
    failureFunction: async ({ error }) => {
      await notifySlack(`Workflow failed: ${error.message}`)
    },
  }
)
```
