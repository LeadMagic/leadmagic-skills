---
title: Use step.do() for Durable Operations
impact: CRITICAL
impactDescription: Ensures operations survive restarts and are retried on failure
tags: workflow, steps, durability, retries
---

## Use step.do() for Durable Operations

Wrap all side effects in `step.do()` to make them durable. Operations inside `step.do()` are persisted and won't re-execute on workflow restart.

**Incorrect (non-durable operations):**

```typescript
export class OrderWorkflow extends WorkflowEntrypoint<Env, OrderParams> {
  async run(event: WorkflowEvent<OrderParams>, step: WorkflowStep) {
    const { orderId } = event.payload

    // ❌ Not durable - will re-execute if workflow restarts
    const order = await this.env.DB
      .prepare('SELECT * FROM orders WHERE id = ?')
      .bind(orderId)
      .first()

    // ❌ Side effect outside step - might send email twice!
    await sendEmail(order.userEmail, 'Order received')

    // ❌ External API call outside step - no retry handling
    const shippingLabel = await fetch('https://shipping.api/create-label', {
      method: 'POST',
      body: JSON.stringify(order),
    })

    return { success: true }
  }
}
```

**Correct (all side effects in durable steps):**

```typescript
export class OrderWorkflow extends WorkflowEntrypoint<Env, OrderParams> {
  async run(event: WorkflowEvent<OrderParams>, step: WorkflowStep) {
    const { orderId } = event.payload

    // ✅ Step 1: Fetch order (durable - result cached)
    const order = await step.do('fetch-order', async () => {
      return await this.env.DB
        .prepare('SELECT * FROM orders WHERE id = ?')
        .bind(orderId)
        .first<Order>()
    })

    if (!order) {
      return { success: false, error: 'Order not found' }
    }

    // ✅ Step 2: Send email (durable - won't send twice)
    await step.do('send-confirmation', async () => {
      await sendEmail(order.userEmail, 'Order received')
    })

    // ✅ Step 3: Create shipping label (with retries)
    const shippingLabel = await step.do('create-shipping-label', {
      retries: {
        limit: 3,
        delay: '10 seconds',
        backoff: 'exponential',
      },
    }, async () => {
      const response = await fetch('https://shipping.api/create-label', {
        method: 'POST',
        body: JSON.stringify({
          orderId: order.id,
          address: order.shippingAddress,
        }),
      })

      if (!response.ok) {
        throw new Error(`Shipping API error: ${response.status}`)
      }

      return response.json()
    })

    // ✅ Step 4: Update order with tracking
    await step.do('update-order-tracking', async () => {
      await this.env.DB
        .prepare('UPDATE orders SET tracking_number = ?, status = ? WHERE id = ?')
        .bind(shippingLabel.trackingNumber, 'shipped', orderId)
        .run()
    })

    return { success: true, trackingNumber: shippingLabel.trackingNumber }
  }
}
```

**Why this matters:**

If your workflow restarts (due to deployment, error, or platform restart):
- Code outside `step.do()` will re-execute
- Code inside completed `step.do()` returns cached result
- This prevents duplicate emails, double charges, etc.

**Step naming best practices:**
- Use descriptive, unique names
- Names are used for state tracking and debugging
- Format: `verb-noun` (e.g., `fetch-order`, `send-email`, `process-payment`)
