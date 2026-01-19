# Checkout Sessions

Create Stripe Checkout sessions for payments and subscriptions.

## Server-Side API Route

```typescript
// app/api/checkout/route.ts
import { stripe } from '@/lib/stripe'
import { auth } from '@clerk/nextjs/server'

export async function POST(req: Request) {
  const { userId } = await auth()
  if (!userId) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { priceId, quantity = 1 } = await req.json()

  // Get or create Stripe customer
  const customer = await getOrCreateCustomer(userId)

  const session = await stripe.checkout.sessions.create({
    customer: customer.id,
    mode: 'subscription', // or 'payment' for one-time
    line_items: [
      {
        price: priceId,
        quantity,
      },
    ],
    success_url: `${process.env.NEXT_PUBLIC_URL}/checkout/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.NEXT_PUBLIC_URL}/pricing`,
    // Important metadata for webhook processing
    metadata: {
      userId,
    },
    subscription_data: {
      metadata: {
        userId,
      },
    },
  })

  return Response.json({ url: session.url })
}
```

## Client-Side Redirect

```typescript
'use client'

import { loadStripe } from '@stripe/stripe-js'

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!)

export function CheckoutButton({ priceId }: { priceId: string }) {
  const [loading, setLoading] = useState(false)

  const handleCheckout = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/checkout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ priceId }),
      })

      const { url } = await response.json()
      window.location.href = url
    } catch (error) {
      console.error('Checkout error:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <button onClick={handleCheckout} disabled={loading}>
      {loading ? 'Loading...' : 'Subscribe'}
    </button>
  )
}
```

## Key Points

1. **Always create sessions server-side** - Never expose secret key
2. **Include metadata** - Link payments to users via userId
3. **Set subscription_data.metadata** - Metadata on checkout doesn't propagate to subscription
4. **Handle success/cancel URLs** - Provide proper redirect destinations
