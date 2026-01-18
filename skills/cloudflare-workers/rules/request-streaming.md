---
title: Stream Large Request/Response Bodies
impact: CRITICAL
impactDescription: Prevents memory issues and enables processing of large payloads
tags: streaming, performance, memory
---

## Stream Large Request/Response Bodies

Use streams for large payloads to avoid loading entire bodies into memory, which can hit Worker memory limits.

**Incorrect (loads entire body into memory):**

```typescript
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // ❌ Loads entire request body into memory
    const body = await request.text()
    const data = JSON.parse(body)

    // ❌ Creates entire response in memory
    const result = await processData(data)
    const responseBody = JSON.stringify(result)

    return new Response(responseBody)
  }
}
```

**Correct (streaming approach):**

```typescript
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // ✅ Stream request body directly to R2
    if (request.method === 'POST' && request.url.includes('/upload')) {
      await env.BUCKET.put('large-file', request.body)
      return new Response('Uploaded', { status: 201 })
    }

    // ✅ Stream response from R2
    if (request.method === 'GET' && request.url.includes('/download')) {
      const object = await env.BUCKET.get('large-file')
      if (!object) {
        return new Response('Not Found', { status: 404 })
      }

      return new Response(object.body, {
        headers: {
          'Content-Type': object.httpMetadata?.contentType ?? 'application/octet-stream',
          'Content-Length': object.size.toString(),
        }
      })
    }

    return new Response('Not Found', { status: 404 })
  }
}

// ✅ Transform stream on the fly
async function transformStream(request: Request): Promise<Response> {
  const { readable, writable } = new TransformStream({
    transform(chunk, controller) {
      // Process each chunk without buffering entire body
      const transformed = processChunk(chunk)
      controller.enqueue(transformed)
    }
  })

  // Pipe in background
  request.body?.pipeTo(writable)

  return new Response(readable)
}

// ✅ Stream JSON array items
async function streamJsonArray(items: AsyncIterable<Item>): Promise<Response> {
  const encoder = new TextEncoder()

  const stream = new ReadableStream({
    async start(controller) {
      controller.enqueue(encoder.encode('['))

      let first = true
      for await (const item of items) {
        if (!first) {
          controller.enqueue(encoder.encode(','))
        }
        controller.enqueue(encoder.encode(JSON.stringify(item)))
        first = false
      }

      controller.enqueue(encoder.encode(']'))
      controller.close()
    }
  })

  return new Response(stream, {
    headers: { 'Content-Type': 'application/json' }
  })
}
```

Workers have 128MB memory limit - streaming prevents hitting this for large files.
