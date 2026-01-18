---
title: Make Steps Idempotent
impact: CRITICAL
impactDescription: Prevents duplicate side effects when steps retry
tags: workflow, idempotency, retries, reliability
---

## Make Steps Idempotent

Design steps so that running them multiple times produces the same result. This is essential because steps may retry on failure.

**Incorrect (non-idempotent operations):**

```typescript
export class PaymentWorkflow extends WorkflowEntrypoint<Env, PaymentParams> {
  async run(event: WorkflowEvent<PaymentParams>, step: WorkflowStep) {
    const { userId, amount } = event.payload

    // ❌ Non-idempotent: Each retry creates a new charge!
    const charge = await step.do('process-payment', {
      retries: { limit: 3 },
    }, async () => {
      return await stripe.charges.create({
        amount,
        currency: 'usd',
        customer: userId,
      })
    })

    // ❌ Non-idempotent: Each retry creates duplicate row!
    await step.do('record-transaction', async () => {
      await this.env.DB
        .prepare('INSERT INTO transactions (user_id, amount) VALUES (?, ?)')
        .bind(userId, amount)
        .run()
    })

    // ❌ Counter increments on each retry
    await step.do('update-stats', async () => {
      await this.env.DB
        .prepare('UPDATE user_stats SET total_spent = total_spent + ? WHERE user_id = ?')
        .bind(amount, userId)
        .run()
    })

    return { chargeId: charge.id }
  }
}
```

**Correct (idempotent operations):**

```typescript
export class PaymentWorkflow extends WorkflowEntrypoint<Env, PaymentParams> {
  async run(event: WorkflowEvent<PaymentParams>, step: WorkflowStep) {
    const { userId, amount, orderId } = event.payload

    // Generate idempotency key from workflow instance
    const idempotencyKey = `order-${orderId}`

    // ✅ Idempotent: Stripe deduplicates with idempotency key
    const charge = await step.do('process-payment', {
      retries: { limit: 3 },
    }, async () => {
      return await stripe.charges.create({
        amount,
        currency: 'usd',
        customer: userId,
      }, {
        idempotencyKey, // Stripe won't create duplicate charges
      })
    })

    // ✅ Idempotent: Use INSERT OR REPLACE / ON CONFLICT
    await step.do('record-transaction', async () => {
      await this.env.DB
        .prepare(`
          INSERT INTO transactions (id, user_id, amount, charge_id, created_at)
          VALUES (?, ?, ?, ?, ?)
          ON CONFLICT (id) DO UPDATE SET
            charge_id = excluded.charge_id
        `)
        .bind(orderId, userId, amount, charge.id, Date.now())
        .run()
    })

    // ✅ Idempotent: Set absolute value, not increment
    await step.do('update-stats', async () => {
      // First, calculate the correct total
      const { results } = await this.env.DB
        .prepare('SELECT SUM(amount) as total FROM transactions WHERE user_id = ?')
        .bind(userId)
        .all()

      const total = results[0]?.total ?? 0

      // Then set it (not increment)
      await this.env.DB
        .prepare(`
          INSERT INTO user_stats (user_id, total_spent)
          VALUES (?, ?)
          ON CONFLICT (user_id) DO UPDATE SET
            total_spent = excluded.total_spent
        `)
        .bind(userId, total)
        .run()
    })

    return { chargeId: charge.id }
  }
}
```

**Idempotency Strategies:**

| Operation | Strategy |
|-----------|----------|
| API calls | Use idempotency keys |
| Database inserts | Use `ON CONFLICT` / `UPSERT` |
| Counters | Recalculate from source, don't increment |
| Emails | Track sent status in database first |
| File uploads | Use consistent object keys |

**Check-then-act pattern:**

```typescript
await step.do('send-welcome-email', async () => {
  // Check if already sent
  const sent = await this.env.DB
    .prepare('SELECT 1 FROM emails_sent WHERE user_id = ? AND type = ?')
    .bind(userId, 'welcome')
    .first()

  if (sent) {
    return { alreadySent: true }
  }

  // Record before sending (in case send succeeds but DB write fails)
  await this.env.DB
    .prepare('INSERT INTO emails_sent (user_id, type, sent_at) VALUES (?, ?, ?)')
    .bind(userId, 'welcome', Date.now())
    .run()

  // Now send
  await sendEmail(userId, 'welcome')

  return { sent: true }
})
```
