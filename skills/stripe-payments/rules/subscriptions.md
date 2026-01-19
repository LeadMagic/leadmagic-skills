# Subscription Management

Handle subscription lifecycle events and modifications.

## Create Subscription with Trial

```typescript
const session = await stripe.checkout.sessions.create({
  customer: customerId,
  mode: 'subscription',
  line_items: [{ price: priceId, quantity: 1 }],
  subscription_data: {
    trial_period_days: 14,
    metadata: { userId },
  },
  success_url: `${baseUrl}/success`,
  cancel_url: `${baseUrl}/pricing`,
})
```

## Cancel Subscription

```typescript
// Cancel at period end (recommended)
await stripe.subscriptions.update(subscriptionId, {
  cancel_at_period_end: true,
})

// Cancel immediately
await stripe.subscriptions.cancel(subscriptionId)
```

## Change Subscription Plan

```typescript
// Get current subscription
const subscription = await stripe.subscriptions.retrieve(subscriptionId)

// Update to new price
await stripe.subscriptions.update(subscriptionId, {
  items: [
    {
      id: subscription.items.data[0].id,
      price: newPriceId,
    },
  ],
  proration_behavior: 'create_prorations',
})
```

## Customer Portal

Let users manage their own subscriptions:

```typescript
// app/api/billing/portal/route.ts
import { stripe } from '@/lib/stripe'
import { auth } from '@clerk/nextjs/server'

export async function POST() {
  const { userId } = await auth()
  if (!userId) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const user = await db.user.findUnique({ where: { id: userId } })
  if (!user?.stripeCustomerId) {
    return Response.json({ error: 'No billing account' }, { status: 400 })
  }

  const session = await stripe.billingPortal.sessions.create({
    customer: user.stripeCustomerId,
    return_url: `${process.env.NEXT_PUBLIC_URL}/settings/billing`,
  })

  return Response.json({ url: session.url })
}
```

## Metered Billing

Report usage for metered subscriptions:

```typescript
await stripe.subscriptionItems.createUsageRecord(
  subscriptionItemId,
  {
    quantity: 100, // Number of units used
    timestamp: Math.floor(Date.now() / 1000),
    action: 'increment', // or 'set'
  }
)
```
