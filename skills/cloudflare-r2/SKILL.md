---
name: cloudflare-r2
description: Best practices for using Cloudflare R2 object storage in Workers. Use when storing files, serving assets, handling uploads/downloads, or implementing storage patterns. Triggers on "R2 storage", "file upload", "object storage", "serve files", "bucket".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.1.0"
---

# Cloudflare R2 Best Practices

Comprehensive guide for using Cloudflare R2 object storage in Workers.

## What's New (2024-2025)

- **Event notifications** - Send messages to Queues on object changes (GA)
- **Lifecycle rules** - Auto-delete or transition objects via Wrangler
- **Infrequent Access** - Storage class for less-accessed data
- **Smart Tiered Cache** - Improved caching for public buckets
- **SSE-C** - Server-side encryption with customer-provided keys

## When to Apply

Reference these guidelines when:
- Storing and retrieving files from R2
- Implementing file upload endpoints
- Serving static assets from R2
- Handling large file transfers
- Reacting to object changes with event notifications

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Operations | CRITICAL | `ops-` |

## Quick Reference

### 1. Operations (CRITICAL)

- `ops-streaming-upload` - Stream uploads for large files

## Essential Patterns

### Basic R2 Operations

```typescript
interface Env {
  BUCKET: R2Bucket
}

// Put object
async function uploadFile(env: Env, key: string, data: ArrayBuffer | ReadableStream) {
  const object = await env.BUCKET.put(key, data, {
    httpMetadata: {
      contentType: 'application/octet-stream',
      cacheControl: 'public, max-age=31536000',
    },
    customMetadata: {
      uploadedAt: new Date().toISOString(),
      uploadedBy: 'user-123',
    },
  })

  return object
}

// Get object
async function getFile(env: Env, key: string): Promise<R2ObjectBody | null> {
  const object = await env.BUCKET.get(key)

  if (!object) {
    return null
  }

  return object
}

// Delete object
async function deleteFile(env: Env, key: string): Promise<void> {
  await env.BUCKET.delete(key)
}

// Check if exists
async function fileExists(env: Env, key: string): Promise<boolean> {
  const head = await env.BUCKET.head(key)
  return head !== null
}
```

### Streaming File Download

```typescript
app.get('/files/:key', async (c) => {
  const key = c.req.param('key')
  const object = await c.env.BUCKET.get(key)

  if (!object) {
    return c.json({ error: 'File not found' }, 404)
  }

  const headers = new Headers()
  headers.set('Content-Type', object.httpMetadata?.contentType ?? 'application/octet-stream')
  headers.set('Content-Length', object.size.toString())
  headers.set('ETag', object.etag)

  if (object.httpMetadata?.cacheControl) {
    headers.set('Cache-Control', object.httpMetadata.cacheControl)
  }

  // Stream the body directly
  return new Response(object.body, { headers })
})
```

### File Upload with Streaming

```typescript
app.post('/upload/:key', async (c) => {
  const key = c.req.param('key')
  const contentType = c.req.header('Content-Type') ?? 'application/octet-stream'

  // Stream request body directly to R2
  const object = await c.env.BUCKET.put(key, c.req.raw.body, {
    httpMetadata: {
      contentType,
    },
  })

  return c.json({
    key: object.key,
    size: object.size,
    etag: object.etag,
  }, 201)
})
```

### Multipart Upload (Large Files)

```typescript
async function uploadLargeFile(
  bucket: R2Bucket,
  key: string,
  stream: ReadableStream,
  partSize: number = 10 * 1024 * 1024 // 10MB parts
): Promise<R2Object> {
  const upload = await bucket.createMultipartUpload(key)

  const reader = stream.getReader()
  const parts: R2UploadedPart[] = []
  let partNumber = 1
  let buffer = new Uint8Array(0)

  try {
    while (true) {
      const { done, value } = await reader.read()

      if (value) {
        // Append to buffer
        const newBuffer = new Uint8Array(buffer.length + value.length)
        newBuffer.set(buffer)
        newBuffer.set(value, buffer.length)
        buffer = newBuffer
      }

      // Upload part when buffer reaches partSize or stream is done
      while (buffer.length >= partSize || (done && buffer.length > 0)) {
        const chunk = buffer.slice(0, partSize)
        buffer = buffer.slice(partSize)

        const part = await upload.uploadPart(partNumber, chunk)
        parts.push(part)
        partNumber++

        if (done && buffer.length === 0) break
      }

      if (done) break
    }

    // Complete the upload
    return await upload.complete(parts)
  } catch (error) {
    // Abort on error
    await upload.abort()
    throw error
  }
}
```

### Range Requests (Video/Audio Streaming)

```typescript
app.get('/media/:key', async (c) => {
  const key = c.req.param('key')
  const range = c.req.header('Range')

  // Get object metadata first
  const head = await c.env.BUCKET.head(key)
  if (!head) {
    return c.json({ error: 'Not found' }, 404)
  }

  const headers = new Headers()
  headers.set('Content-Type', head.httpMetadata?.contentType ?? 'application/octet-stream')
  headers.set('Accept-Ranges', 'bytes')
  headers.set('ETag', head.etag)

  if (range) {
    // Parse range header
    const match = range.match(/bytes=(\d+)-(\d*)/)
    if (match) {
      const start = parseInt(match[1])
      const end = match[2] ? parseInt(match[2]) : head.size - 1

      const object = await c.env.BUCKET.get(key, {
        range: { offset: start, length: end - start + 1 },
      })

      if (!object) {
        return c.json({ error: 'Not found' }, 404)
      }

      headers.set('Content-Range', `bytes ${start}-${end}/${head.size}`)
      headers.set('Content-Length', (end - start + 1).toString())

      return new Response(object.body, {
        status: 206,
        headers,
      })
    }
  }

  // Full file
  const object = await c.env.BUCKET.get(key)
  if (!object) {
    return c.json({ error: 'Not found' }, 404)
  }

  headers.set('Content-Length', object.size.toString())
  return new Response(object.body, { headers })
})
```

### Listing Objects with Pagination

```typescript
app.get('/files', async (c) => {
  const prefix = c.req.query('prefix') ?? ''
  const cursor = c.req.query('cursor')
  const limit = parseInt(c.req.query('limit') ?? '100')

  const listed = await c.env.BUCKET.list({
    prefix,
    cursor,
    limit,
    include: ['httpMetadata', 'customMetadata'],
  })

  return c.json({
    objects: listed.objects.map(obj => ({
      key: obj.key,
      size: obj.size,
      uploaded: obj.uploaded,
      etag: obj.etag,
      contentType: obj.httpMetadata?.contentType,
      metadata: obj.customMetadata,
    })),
    truncated: listed.truncated,
    cursor: listed.truncated ? listed.cursor : undefined,
  })
})
```

### Conditional Requests (ETags)

```typescript
app.get('/files/:key', async (c) => {
  const key = c.req.param('key')
  const ifNoneMatch = c.req.header('If-None-Match')

  // Check ETag first with head()
  const head = await c.env.BUCKET.head(key)
  if (!head) {
    return c.json({ error: 'Not found' }, 404)
  }

  // Return 304 if ETag matches
  if (ifNoneMatch && ifNoneMatch === head.etag) {
    return new Response(null, { status: 304 })
  }

  const object = await c.env.BUCKET.get(key)
  if (!object) {
    return c.json({ error: 'Not found' }, 404)
  }

  return new Response(object.body, {
    headers: {
      'Content-Type': object.httpMetadata?.contentType ?? 'application/octet-stream',
      'ETag': object.etag,
      'Cache-Control': 'public, max-age=3600',
    },
  })
})
```

### Presigned URL Generation

```typescript
// Note: R2 presigned URLs require using the S3-compatible API
// This is typically done server-side for direct browser uploads

import { AwsClient } from 'aws4fetch'

async function generatePresignedUrl(
  env: Env,
  key: string,
  expiresIn: number = 3600
): Promise<string> {
  const client = new AwsClient({
    accessKeyId: env.R2_ACCESS_KEY_ID,
    secretAccessKey: env.R2_SECRET_ACCESS_KEY,
  })

  const url = new URL(`https://${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com/${env.BUCKET_NAME}/${key}`)
  url.searchParams.set('X-Amz-Expires', expiresIn.toString())

  const signed = await client.sign(url.toString(), {
    method: 'PUT',
    aws: { signQuery: true },
  })

  return signed.url
}
```

## Wrangler Configuration

```toml
[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"
preview_bucket_name = "my-bucket-preview"

# For presigned URLs (S3 API)
[vars]
R2_ACCOUNT_ID = "your-account-id"
BUCKET_NAME = "my-bucket"
```

## Event Notifications (GA)

```typescript
// Receive R2 events via Queue consumer
export default {
  async queue(batch: MessageBatch<R2EventMessage>, env: Env) {
    for (const message of batch.messages) {
      const event = message.body
      console.log(`${event.action} on ${event.object.key}`)
      
      if (event.action === 'PutObject') {
        await processNewObject(env, event.object.key)
      }
      message.ack()
    }
  },
}

interface R2EventMessage {
  account: string
  bucket: string
  action: 'PutObject' | 'CopyObject' | 'DeleteObject' | 'LifecycleDeletion'
  object: { key: string; size?: number; eTag?: string }
  eventTime: string
}
```

```bash
# Enable via Wrangler
wrangler r2 bucket notification create my-bucket \
  --event-type object-create \
  --queue MY_QUEUE \
  --prefix "uploads/"
```

## R2 Limits

| Resource | Limit |
|----------|-------|
| Max object size | 5TB |
| Max object size (single PUT) | 5GB |
| Max multipart part size | 5GB |
| Min multipart part size | 5MB |
| Max parts per multipart upload | 10,000 |
| Free egress | Unlimited to Workers |
| Event notification rules | 100 per bucket |

