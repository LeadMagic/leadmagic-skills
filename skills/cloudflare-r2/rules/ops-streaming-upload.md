---
title: Stream Uploads for Large Files
impact: HIGH
impactDescription: Avoids memory limits, enables unlimited file sizes
tags: streaming, upload, performance
---

## Stream Uploads for Large Files

Stream request bodies directly to R2 instead of buffering in memory. This avoids the 128MB Worker memory limit.

**Incorrect (buffers entire file in memory):**

```typescript
app.post('/upload/:key', async (c) => {
  const key = c.req.param('key')

  // ❌ Loads entire file into Worker memory
  const body = await c.req.arrayBuffer()

  // ❌ For large files, this will crash the Worker
  await c.env.BUCKET.put(key, body)

  return c.json({ uploaded: true })
})
```

**Correct (stream directly to R2):**

```typescript
app.post('/upload/:key', async (c) => {
  const key = c.req.param('key')
  const contentType = c.req.header('Content-Type') ?? 'application/octet-stream'
  const contentLength = c.req.header('Content-Length')

  // ✅ Stream request body directly to R2
  // Body never fully loaded into memory
  const object = await c.env.BUCKET.put(key, c.req.raw.body, {
    httpMetadata: {
      contentType,
    },
    customMetadata: {
      uploadedAt: new Date().toISOString(),
      originalSize: contentLength ?? 'unknown',
    },
  })

  return c.json({
    key: object.key,
    size: object.size,
    etag: object.etag,
    uploaded: object.uploaded.toISOString(),
  }, 201)
})

// ✅ Multipart upload for very large files (>5GB)
app.post('/upload-large/:key', async (c) => {
  const key = c.req.param('key')
  const body = c.req.raw.body

  if (!body) {
    return c.json({ error: 'No body provided' }, 400)
  }

  // Start multipart upload
  const upload = await c.env.BUCKET.createMultipartUpload(key)

  const reader = body.getReader()
  const parts: R2UploadedPart[] = []
  let partNumber = 1
  const partSize = 10 * 1024 * 1024 // 10MB parts
  let buffer = new Uint8Array(0)

  try {
    while (true) {
      const { done, value } = await reader.read()

      if (value) {
        // Append chunk to buffer
        const newBuffer = new Uint8Array(buffer.length + value.length)
        newBuffer.set(buffer)
        newBuffer.set(value, buffer.length)
        buffer = newBuffer
      }

      // Upload parts when buffer is large enough
      while (buffer.length >= partSize) {
        const chunk = buffer.slice(0, partSize)
        buffer = buffer.slice(partSize)

        const part = await upload.uploadPart(partNumber, chunk)
        parts.push(part)
        partNumber++
      }

      if (done) {
        // Upload remaining data as final part
        if (buffer.length > 0) {
          const part = await upload.uploadPart(partNumber, buffer)
          parts.push(part)
        }
        break
      }
    }

    // Complete the multipart upload
    const object = await upload.complete(parts)

    return c.json({
      key: object.key,
      size: object.size,
      parts: parts.length,
    }, 201)
  } catch (error) {
    // Abort on any error to clean up partial upload
    await upload.abort()
    throw error
  }
})

// ✅ With progress tracking via Durable Object
app.post('/upload-tracked/:key', async (c) => {
  const key = c.req.param('key')
  const uploadId = crypto.randomUUID()
  const contentLength = parseInt(c.req.header('Content-Length') ?? '0')

  // Create tracking DO
  const trackerId = c.env.UPLOAD_TRACKER.idFromName(uploadId)
  const tracker = c.env.UPLOAD_TRACKER.get(trackerId)

  // Initialize tracking
  await tracker.init(key, contentLength)

  // Transform stream to track progress
  let uploaded = 0
  const trackingStream = new TransformStream({
    async transform(chunk, controller) {
      uploaded += chunk.length

      // Update progress (fire and forget)
      tracker.updateProgress(uploaded).catch(() => {})

      controller.enqueue(chunk)
    }
  })

  // Pipe request through tracking stream to R2
  const body = c.req.raw.body?.pipeThrough(trackingStream)

  const object = await c.env.BUCKET.put(key, body)

  // Mark complete
  await tracker.complete()

  return c.json({
    uploadId,
    key: object.key,
    size: object.size,
  }, 201)
})
```

**Memory usage:**
- Buffered: Entire file size (fails at >128MB)
- Streamed: ~64KB buffer (works for any file size)
