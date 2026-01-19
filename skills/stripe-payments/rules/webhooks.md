# Webhook Handling

Securely handle Stripe webhooks with signature verification.

## Webhook Endpoint

```typescript
// app/api/webhooks/stripe/route.ts
import { stripe } from '@/lib/stripe'
import { headers } from 'next/headers'

export async function POST(req: Request) {
  const body = await req.text()
  const signature = headers().get('stripe-signature')!

  let event: Stripe.Event

  // CRITICAL: Always verify webhook signature
  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (err) {
    console.error('Webhook signature verification failed:', err)
    return Response.json({ error: 'Invalid signature' }, { status: 400 })
  }

  // Handle the event
  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutComplete(event.data.object)
        break

      case 'customer.subscription.created':
        await handleSubscriptionCreated(event.data.object)
        break

      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object)
        break

      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object)
        break

      case 'invoice.payment_succeeded':
        await handleInvoicePaid(event.data.object)
        break

      case 'invoice.payment_failed':
        await handleInvoiceFailed(event.data.object)
        break

      default:
        console.log(`Unhandled event type: ${event.type}`)
    }

    return Response.json({ received: true })
  } catch (error) {
    console.error('Webhook handler error:', error)
    // Return 200 to prevent retries for handler errors
    return Response.json({ received: true })
  }
}
```

## Event Handlers

```typescript
// lib/stripe/handlers.ts
import { db } from '@/lib/db'

export async function handleCheckoutComplete(
  session: Stripe.Checkout.Session
) {
  const userId = session.metadata?.userId
  if (!userId) {
    throw new Error('No userId in session metadata')
  }

  await db.user.update({
    where: { id: userId },
    data: {
      stripeCustomerId: session.customer as string,
      subscriptionStatus: 'active',
    },
  })
}

export async function handleSubscriptionUpdated(
  subscription: Stripe.Subscription
) {
  const userId = subscription.metadata?.userId
  if (!userId) return

  await db.user.update({
    where: { id: userId },
    data: {
      subscriptionStatus: subscription.status,
      subscriptionId: subscription.id,
      currentPeriodEnd: new Date(subscription.current_period_end * 1000),
      cancelAtPeriodEnd: subscription.cancel_at_period_end,
    },
  })
}

export async function handleInvoiceFailed(invoice: Stripe.Invoice) {
  const customerId = invoice.customer as string
  const user = await db.user.findFirst({
    where: { stripeCustomerId: customerId },
  })

  if (user) {
    await sendPaymentFailedEmail(user.email)
    await db.user.update({
      where: { id: user.id },
      data: { subscriptionStatus: 'past_due' },
    })
  }
}
```

## Security Notes

1. **Always verify signatures** - Never process unverified webhooks
2. **Use raw body** - Don't parse JSON before verification
3. **Return 200 for handler errors** - Prevent infinite retries
4. **Log all events** - Essential for debugging
