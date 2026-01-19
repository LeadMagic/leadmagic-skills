# Realtime (SDK v3.0+)

Stream updates from Inngest functions to clients in real-time.

## Setup Channels

```typescript
// lib/inngest/channels.ts
import { channel, topic } from '@inngest/realtime'
import { z } from 'zod'

// Create a channel for each user/thread/resource
export const userChannel = channel((userId: string) => `user:${userId}`)
  .addTopic(
    topic('notifications').schema(
      z.object({
        type: z.string(),
        message: z.string(),
      })
    )
  )
  .addTopic(
    topic('progress').schema(
      z.object({
        percent: z.number(),
        status: z.string(),
      })
    )
  )
```

## Publish from Functions

```typescript
import { inngest } from './client'
import { userChannel } from './channels'

export const processUpload = inngest.createFunction(
  { id: 'process-upload', retries: 3 },
  { event: 'upload/started' },
  async ({ event, step, publish }) => {
    const { userId, fileId } = event.data

    await publish(
      userChannel(userId).progress({ percent: 0, status: 'Starting...' })
    )

    await step.run('process-file', async () => {
      // Process in chunks, publishing progress
      for (let i = 0; i <= 100; i += 10) {
        await processChunk(fileId, i)
        await publish(
          userChannel(userId).progress({ percent: i, status: 'Processing...' })
        )
      }
    })

    await publish(
      userChannel(userId).notifications({
        type: 'success',
        message: 'Upload complete!',
      })
    )

    return { success: true }
  }
)
```

## Subscribe in React

```typescript
// app/page.tsx
'use client'

import { useInngestSubscription } from '@inngest/realtime/hooks'

export default function UploadProgress({ userId }: { userId: string }) {
  const { data, latestData, state } = useInngestSubscription({
    refreshToken: async () => {
      // Server action to get subscription token
      const res = await fetch('/api/realtime-token', {
        method: 'POST',
        body: JSON.stringify({ channel: `user:${userId}`, topics: ['progress'] }),
      })
      return res.json()
    },
  })

  return (
    <div>
      {state === 'connected' && latestData && (
        <div>
          <progress value={latestData.percent} max={100} />
          <p>{latestData.status}</p>
        </div>
      )}
    </div>
  )
}
```

## Server Action for Tokens

```typescript
// app/api/realtime-token/route.ts
import { inngest } from '@/lib/inngest'

export async function POST(req: Request) {
  const { channel, topics } = await req.json()

  // Verify user has access to this channel
  const { userId } = await auth()
  if (!channel.startsWith(`user:${userId}`)) {
    return Response.json({ error: 'Unauthorized' }, { status: 403 })
  }

  const token = await inngest.realtime.createToken({
    channel,
    topics,
  })

  return Response.json({ token })
}
```

## Use Cases

- **Progress bars** - Show upload/processing progress
- **Live updates** - Real-time notifications
- **AI streaming** - Stream LLM responses
- **Collaboration** - Multi-user updates
