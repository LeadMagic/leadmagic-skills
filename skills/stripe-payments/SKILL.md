---
name: stripe-payments
description: Stripe payment integration patterns for Next.js and serverless. Use when implementing checkout, subscriptions, webhooks, or payment processing. Triggers on "payment", "stripe", "checkout", "subscription", "billing", "invoice", "webhook".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.2.0"
  context7: stripe/stripe-node
---

# Stripe Payments Integration

Comprehensive guide for integrating Stripe payments in Next.js applications with serverless backends.

## What's New (Clover API 2025)

- **Accounts v2** - New account management for Connect platforms
- **Payment Records** - Track non-Stripe payments alongside Stripe payments
- **Custom payment methods** - Add your own payment method types
- **MB WAY, TWINT, PayTo** - New payment methods supported

## When to Apply

Reference these guidelines when:
- Implementing Stripe Checkout sessions
- Building subscription billing systems
- Processing webhooks reliably
- Creating customer portals
- Handling payment methods
- Managing invoices and refunds

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Webhook Security | CRITICAL | `webhook-` |
| 2 | Checkout Flow | HIGH | `checkout-` |
| 3 | Subscriptions | HIGH | `subscription-` |
| 4 | Error Handling | MEDIUM | `errors-` |

## Quick Reference

### 1. Webhook Security (CRITICAL)

- `webhook-signature` - Always verify webhook signatures
- `webhook-idempotency` - Handle duplicate events

### 2. Checkout Flow (HIGH)

- `checkout-sessions` - Create checkout sessions server-side
- `checkout-metadata` - Pass metadata for tracking

### 3. Subscriptions (HIGH)

- `subscription-lifecycle` - Handle all subscription events
- `subscription-trials` - Implement trial periods correctly

---

## Installation

```bash
npm install stripe @stripe/stripe-js
```

## Environment Setup

```bash
# .env.local
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_xxx
```

---

## Server-Side Setup

```typescript
// lib/stripe.ts
import Stripe from 'stripe'

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2025-12-15.clover',  // Latest API version
  typescript: true,
})
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| No signature verification | Security vulnerability | Always verify signatures |
| Missing metadata | Can't link payment to user | Include userId in metadata |
| Sync webhook processing | Slow responses, timeouts | Use async processing |
| Hardcoded prices | Hard to update | Use Price IDs from Stripe |
| No idempotency | Duplicate processing | Check event ID before processing |
| Exposing secret key | Security vulnerability | Only use on server |

---

## Best Practices

### Do

- Always verify webhook signatures
- Include userId in metadata for all objects
- Handle all subscription lifecycle events
- Use Stripe Customer Portal for self-service
- Test with Stripe CLI locally
- Log all webhook events for debugging

### Don't

- Don't expose secret key to client
- Don't trust client-side price data
- Don't skip webhook signature verification
- Don't process webhooks synchronously for heavy operations
- Don't store full card numbers (use Stripe's tokenization)

---

## Subscription Status Reference

| Status | Meaning | Action |
|--------|---------|--------|
| `active` | Paid and current | Full access |
| `trialing` | In trial period | Full access |
| `past_due` | Payment failed | Grace period, prompt for update |
| `canceled` | Subscription ended | Revoke access |
| `unpaid` | Multiple failures | Revoke access |
| `incomplete` | Initial payment failed | Prompt to complete |

---

## How to Use

Read individual rule files for detailed patterns:

```
rules/checkout-sessions.md   - Create checkout sessions
rules/webhooks.md            - Secure webhook handling
rules/subscriptions.md       - Subscription management
rules/customer-portal.md     - Self-service billing
rules/testing.md             - Test cards and CLI
```

## Resources

- [Stripe Documentation](https://stripe.com/docs)
- [Stripe API Reference](https://stripe.com/docs/api)
- [Checkout Sessions](https://stripe.com/docs/payments/checkout)
- [Webhooks](https://stripe.com/docs/webhooks)
- [Testing](https://stripe.com/docs/testing)
