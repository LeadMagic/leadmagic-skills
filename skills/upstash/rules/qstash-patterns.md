---
title: QStash Message Queue Patterns
impact: CRITICAL
impactDescription: Background jobs, scheduling, and callbacks
tags: qstash, queue, scheduling, cron
---

## QStash Message Queue Patterns

### Publish Messages

```typescript
import { Client } from "@upstash/qstash"

const qstash = new Client({ token: process.env.QSTASH_TOKEN! })

// Simple message
const result = await qstash.publishJSON({
  url: `${process.env.NEXT_PUBLIC_APP_URL}/api/process`,
  body: { userId: "123" },
})

// With delay
await qstash.publishJSON({
  url: `${process.env.NEXT_PUBLIC_APP_URL}/api/process`,
  body: data,
  delay: 60, // 60 seconds
})

// With retries and callback
await qstash.publishJSON({
  url: `${process.env.NEXT_PUBLIC_APP_URL}/api/process`,
  body: data,
  retries: 3,
  callback: `${process.env.NEXT_PUBLIC_APP_URL}/api/callback`,
  failureCallback: `${process.env.NEXT_PUBLIC_APP_URL}/api/failure`,
})
```

### Receive & Verify Messages

```typescript
// app/api/process/route.ts
import { verifySignatureAppRouter } from "@upstash/qstash/nextjs"

async function handler(req: Request) {
  const body = await req.json()
  console.log("Processing:", body)
  return new Response("OK", { status: 200 })
}

// Wrap handler to verify QStash signature
export const POST = verifySignatureAppRouter(handler)
```

### Cron Schedules

```typescript
// Create a schedule
const schedule = await qstash.schedules.create({
  destination: `${process.env.NEXT_PUBLIC_APP_URL}/api/daily-task`,
  cron: "0 9 * * *", // Daily at 9 AM
  callback: `${process.env.NEXT_PUBLIC_APP_URL}/api/callback`,
  failureCallback: `${process.env.NEXT_PUBLIC_APP_URL}/api/failure`,
})

// List schedules
const schedules = await qstash.schedules.list()

// Delete schedule
await qstash.schedules.delete(schedule.scheduleId)
```

### Handle Callbacks

```typescript
import { verifySignatureAppRouter } from "@upstash/qstash/nextjs"

interface QStashCallback {
  status: number
  body: string // Base64 encoded
  retried: number
  maxRetries: number
  sourceMessageId: string
}

async function handler(req: Request) {
  const callback: QStashCallback = await req.json()
  const responseBody = atob(callback.body) // Decode base64

  if (callback.status === 200) {
    console.log("Task succeeded:", callback.sourceMessageId)
  } else {
    console.log(`Task failed (attempt ${callback.retried}/${callback.maxRetries})`)
  }

  return new Response("OK", { status: 200 })
}

export const POST = verifySignatureAppRouter(handler)
```
