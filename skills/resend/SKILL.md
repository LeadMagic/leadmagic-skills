---
name: resend
description: Resend email API with React Email templates. Use when sending transactional emails, building email templates, or managing email delivery. Triggers on "email", "Resend", "React Email", "send email", "transactional email".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Resend - Email API

Modern email API built for developers, with React Email support.

## Installation

```bash
npm install resend
npm install @react-email/components  # For templates
```

## Environment Variables

```bash
RESEND_API_KEY=re_...
```

---

## Basic Usage

```typescript
import { Resend } from 'resend'

const resend = new Resend(process.env.RESEND_API_KEY)

// Send simple email
const { data, error } = await resend.emails.send({
  from: 'noreply@yourdomain.com',
  to: 'user@example.com',
  subject: 'Welcome!',
  html: '<h1>Welcome to our app!</h1>',
})

if (error) {
  console.error('Failed to send:', error)
  return
}

console.log('Email sent:', data.id)
```

---

## React Email Templates

### Template Component

```tsx
// emails/welcome.tsx
import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Img,
  Link,
  Preview,
  Section,
  Text,
} from '@react-email/components'

interface WelcomeEmailProps {
  name: string
  actionUrl: string
}

export function WelcomeEmail({ name, actionUrl }: WelcomeEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Welcome to our platform, {name}!</Preview>
      <Body style={main}>
        <Container style={container}>
          <Img
            src="https://yourdomain.com/logo.png"
            width="120"
            height="40"
            alt="Logo"
          />
          <Heading style={h1}>Welcome, {name}!</Heading>
          <Text style={text}>
            Thanks for signing up. We're excited to have you on board.
          </Text>
          <Section style={buttonContainer}>
            <Button style={button} href={actionUrl}>
              Get Started
            </Button>
          </Section>
          <Text style={footer}>
            If you didn't create an account, you can ignore this email.
          </Text>
        </Container>
      </Body>
    </Html>
  )
}

const main = {
  backgroundColor: '#f6f9fc',
  fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
}

const container = {
  backgroundColor: '#ffffff',
  margin: '0 auto',
  padding: '40px 20px',
  maxWidth: '560px',
}

const h1 = {
  color: '#1f2937',
  fontSize: '24px',
  fontWeight: '600',
  margin: '30px 0',
}

const text = {
  color: '#4b5563',
  fontSize: '16px',
  lineHeight: '24px',
  margin: '16px 0',
}

const buttonContainer = {
  margin: '32px 0',
}

const button = {
  backgroundColor: '#2563eb',
  borderRadius: '6px',
  color: '#fff',
  fontSize: '16px',
  fontWeight: '600',
  padding: '12px 24px',
  textDecoration: 'none',
}

const footer = {
  color: '#9ca3af',
  fontSize: '14px',
  marginTop: '32px',
}

export default WelcomeEmail
```

### Send with Template

```typescript
import { Resend } from 'resend'
import { WelcomeEmail } from '@/emails/welcome'

const resend = new Resend(process.env.RESEND_API_KEY)

export async function sendWelcomeEmail(email: string, name: string) {
  const { data, error } = await resend.emails.send({
    from: 'Team <team@yourdomain.com>',
    to: email,
    subject: `Welcome to our platform, ${name}!`,
    react: WelcomeEmail({ name, actionUrl: 'https://app.yourdomain.com' }),
  })

  return { data, error }
}
```

---

## Next.js API Route

```typescript
// app/api/send-email/route.ts
import { Resend } from 'resend'
import { WelcomeEmail } from '@/emails/welcome'

const resend = new Resend(process.env.RESEND_API_KEY)

export async function POST(request: Request) {
  const { email, name } = await request.json()

  const { data, error } = await resend.emails.send({
    from: 'Team <team@yourdomain.com>',
    to: email,
    subject: 'Welcome!',
    react: WelcomeEmail({ name, actionUrl: 'https://app.yourdomain.com' }),
  })

  if (error) {
    return Response.json({ error }, { status: 400 })
  }

  return Response.json({ id: data?.id })
}
```

---

## Common Email Templates

### Password Reset

```tsx
// emails/reset-password.tsx
import { Button, Text, Html, Head, Body, Container } from '@react-email/components'

interface ResetPasswordProps {
  resetUrl: string
  expiresIn: string
}

export function ResetPasswordEmail({ resetUrl, expiresIn }: ResetPasswordProps) {
  return (
    <Html>
      <Head />
      <Body style={main}>
        <Container style={container}>
          <Text style={text}>
            You requested a password reset. Click the button below to set a new password.
          </Text>
          <Button style={button} href={resetUrl}>
            Reset Password
          </Button>
          <Text style={small}>
            This link expires in {expiresIn}. If you didn't request this, ignore this email.
          </Text>
        </Container>
      </Body>
    </Html>
  )
}
```

### Invoice/Receipt

```tsx
// emails/receipt.tsx
import { Html, Head, Body, Container, Section, Row, Column, Text } from '@react-email/components'

interface ReceiptProps {
  customerName: string
  items: { name: string; quantity: number; price: number }[]
  total: number
}

export function ReceiptEmail({ customerName, items, total }: ReceiptProps) {
  return (
    <Html>
      <Head />
      <Body style={main}>
        <Container style={container}>
          <Text style={h1}>Receipt</Text>
          <Text>Thank you for your purchase, {customerName}!</Text>

          <Section style={table}>
            {items.map((item, i) => (
              <Row key={i} style={row}>
                <Column>{item.name}</Column>
                <Column style={right}>x{item.quantity}</Column>
                <Column style={right}>${item.price.toFixed(2)}</Column>
              </Row>
            ))}
            <Row style={totalRow}>
              <Column>Total</Column>
              <Column style={right}></Column>
              <Column style={right}>${total.toFixed(2)}</Column>
            </Row>
          </Section>
        </Container>
      </Body>
    </Html>
  )
}
```

---

## Advanced Features

### Attachments

```typescript
await resend.emails.send({
  from: 'team@yourdomain.com',
  to: 'user@example.com',
  subject: 'Your Invoice',
  react: InvoiceEmail({ ... }),
  attachments: [
    {
      filename: 'invoice.pdf',
      content: pdfBuffer, // Buffer or base64 string
    },
  ],
})
```

### Batch Sending

```typescript
const { data, error } = await resend.batch.send([
  {
    from: 'team@yourdomain.com',
    to: 'user1@example.com',
    subject: 'Hello User 1',
    html: '<p>Hello!</p>',
  },
  {
    from: 'team@yourdomain.com',
    to: 'user2@example.com',
    subject: 'Hello User 2',
    html: '<p>Hello!</p>',
  },
])
```

### Scheduled Emails

```typescript
await resend.emails.send({
  from: 'team@yourdomain.com',
  to: 'user@example.com',
  subject: 'Scheduled Email',
  html: '<p>This was scheduled!</p>',
  scheduledAt: '2025-01-20T10:00:00Z', // ISO 8601
})
```

### Reply-To & CC/BCC

```typescript
await resend.emails.send({
  from: 'noreply@yourdomain.com',
  to: 'user@example.com',
  cc: ['manager@example.com'],
  bcc: ['archive@yourdomain.com'],
  replyTo: 'support@yourdomain.com',
  subject: 'Your Request',
  html: '<p>...</p>',
})
```

---

## Email Preview (Development)

```bash
# Install CLI
npm install -g react-email

# Start preview server
npx react-email dev --dir ./emails
```

This opens a browser with live preview of your templates.

---

## Domain Setup

1. Add domain in Resend dashboard
2. Add DNS records:
   - SPF: `v=spf1 include:amazonses.com ~all`
   - DKIM: Provided by Resend
   - DMARC: `v=DMARC1; p=none;`
3. Verify domain
4. Update `from` address to use verified domain

---

## Webhooks

```typescript
// app/api/webhooks/resend/route.ts
import { Webhook } from 'svix'

export async function POST(request: Request) {
  const payload = await request.text()
  const headers = Object.fromEntries(request.headers)

  const wh = new Webhook(process.env.RESEND_WEBHOOK_SECRET!)

  try {
    const event = wh.verify(payload, headers)

    switch (event.type) {
      case 'email.sent':
        console.log('Email sent:', event.data.email_id)
        break
      case 'email.delivered':
        console.log('Email delivered:', event.data.email_id)
        break
      case 'email.bounced':
        await handleBounce(event.data.email_id, event.data.to)
        break
      case 'email.complained':
        await handleComplaint(event.data.to)
        break
    }

    return Response.json({ received: true })
  } catch (err) {
    return Response.json({ error: 'Invalid signature' }, { status: 400 })
  }
}
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using unverified domain | Verify domain in Resend dashboard |
| No error handling | Always check `error` in response |
| Missing preview text | Add `<Preview>` component |
| Inline styles not working | Use React Email's style objects |
| Large attachments | Keep under 40MB |

---

## Quick Reference

| Feature | Code |
|---------|------|
| Send email | `resend.emails.send({ ... })` |
| Batch send | `resend.batch.send([...])` |
| With template | `react: MyTemplate({ props })` |
| Attachment | `attachments: [{ filename, content }]` |
| Schedule | `scheduledAt: '2025-01-20T10:00:00Z'` |
| Preview | `npx react-email dev --dir ./emails` |

## References

- [Resend Docs](https://resend.com/docs)
- [React Email](https://react.email)
- [React Email Components](https://react.email/docs/components/html)
