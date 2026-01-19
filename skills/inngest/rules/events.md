# Events

Define typed events and trigger functions.

## Define Event Schema

```typescript
// lib/inngest/events.ts
type Events = {
  'user/created': {
    data: {
      userId: string
      email: string
      name: string
    }
  }
  'order/created': {
    data: {
      orderId: string
      userId: string
      items: Array<{ productId: string; quantity: number }>
      total: number
    }
  }
  'email/send': {
    data: {
      to: string
      template: string
      variables: Record<string, string>
    }
  }
}

export const inngest = new Inngest({
  id: 'my-app',
  schemas: new EventSchemas().fromRecord<Events>(),
})
```

## Sending Events

```typescript
// Single event
await inngest.send({
  name: 'order/created',
  data: {
    orderId: order.id,
    userId: user.id,
    items: order.items,
    total: order.total,
  },
})

// Multiple events
await inngest.send([
  { name: 'user/created', data: { userId, email, name } },
  { name: 'email/send', data: { to: email, template: 'welcome' } },
])
```

## Event Triggers

```typescript
// Single event trigger
export const onUserCreated = inngest.createFunction(
  { id: 'on-user-created' },
  { event: 'user/created' },
  async ({ event }) => {
    // event.data is typed
  }
)

// Cron trigger
export const dailyReport = inngest.createFunction(
  { id: 'daily-report' },
  { cron: '0 9 * * *' }, // 9 AM daily
  async ({ step }) => {
    const data = await step.run('gather-data', gatherReportData)
    await step.run('send-report', () => sendReportEmail(data))
  }
)

// Multiple triggers
export const syncUser = inngest.createFunction(
  { id: 'sync-user' },
  [
    { event: 'user/created' },
    { event: 'user/updated' },
  ],
  async ({ event }) => {
    // Triggered by either event
  }
)
```

## From Webhooks

Forward webhooks to Inngest for reliable processing:

```typescript
// app/api/webhooks/stripe/route.ts
export async function POST(req: Request) {
  const event = await req.json()

  // Forward to Inngest for reliable processing
  await inngest.send({
    name: 'stripe/webhook',
    data: event,
  })

  return new Response('OK', { status: 200 })
}

// Process webhook with retries
export const handleStripeWebhook = inngest.createFunction(
  { id: 'stripe-webhook', retries: 5 },
  { event: 'stripe/webhook' },
  async ({ event, step }) => {
    const stripeEvent = event.data

    switch (stripeEvent.type) {
      case 'checkout.session.completed':
        await step.run('fulfill-order', async () => {
          await fulfillOrder(stripeEvent.data.object)
        })
        break
    }
  }
)
```
