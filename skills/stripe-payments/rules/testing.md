# Testing Stripe

Test cards and local webhook testing.

## Test Cards

| Scenario | Card Number |
|----------|-------------|
| Success | 4242 4242 4242 4242 |
| Decline | 4000 0000 0000 0002 |
| Requires Auth | 4000 0025 0000 3155 |
| Insufficient Funds | 4000 0000 0000 9995 |
| Expired | 4000 0000 0000 0069 |
| Processing Error | 4000 0000 0000 0119 |

Use any future expiry date, any 3-digit CVC, and any postal code.

## Stripe CLI for Webhooks

```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe

# Login
stripe login

# Forward webhooks to local endpoint
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# In another terminal, trigger test events
stripe trigger checkout.session.completed
stripe trigger customer.subscription.updated
stripe trigger invoice.payment_failed
```

## Copy Webhook Secret

When running `stripe listen`, copy the webhook signing secret:

```
Ready! Your webhook signing secret is whsec_xxxxx
```

Add to your `.env.local`:

```bash
STRIPE_WEBHOOK_SECRET=whsec_xxxxx
```

## Test Subscription Lifecycle

```bash
# Create a subscription
stripe trigger customer.subscription.created

# Simulate payment success
stripe trigger invoice.payment_succeeded

# Simulate payment failure
stripe trigger invoice.payment_failed

# Cancel subscription
stripe trigger customer.subscription.deleted
```

## One-Time Payment Testing

```typescript
// Server: Create payment intent
const paymentIntent = await stripe.paymentIntents.create({
  amount: 2000, // $20.00 in cents
  currency: 'usd',
  metadata: { orderId },
})

return { clientSecret: paymentIntent.client_secret }
```

## Important Notes

- Test mode and live mode use different API keys
- Webhook endpoints are separate for test/live
- Always test the full flow before going live
- Use Stripe Dashboard > Developers > Webhooks to monitor events
