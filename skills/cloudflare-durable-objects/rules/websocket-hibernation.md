---
title: Use Hibernatable WebSockets API
impact: HIGH
impactDescription: 10-100x cost reduction for WebSocket connections
tags: websocket, hibernation, cost
---

## Use Hibernatable WebSockets API

Use the Hibernatable WebSockets API to allow your Durable Object to hibernate between messages, dramatically reducing costs.

**Incorrect (non-hibernatable, billed for entire connection duration):**

```typescript
export class ChatRoom extends DurableObject {
  private connections: Set<WebSocket> = new Set()

  async fetch(request: Request): Promise<Response> {
    const upgradeHeader = request.headers.get('Upgrade')
    if (upgradeHeader !== 'websocket') {
      return new Response('Expected WebSocket', { status: 426 })
    }

    const pair = new WebSocketPair()
    const [client, server] = Object.values(pair)

    // ❌ Manual WebSocket handling - DO stays awake entire time
    server.accept()
    this.connections.add(server)

    server.addEventListener('message', (event) => {
      this.broadcast(event.data as string)
    })

    server.addEventListener('close', () => {
      this.connections.delete(server)
    })

    return new Response(null, { status: 101, webSocket: client })
  }

  private broadcast(message: string) {
    for (const ws of this.connections) {
      ws.send(message)
    }
  }
}
```

**Correct (hibernatable, only billed when processing messages):**

```typescript
export class ChatRoom extends DurableObject {
  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env)
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url)

    if (url.pathname === '/websocket') {
      const upgradeHeader = request.headers.get('Upgrade')
      if (upgradeHeader !== 'websocket') {
        return new Response('Expected WebSocket', { status: 426 })
      }

      const pair = new WebSocketPair()
      const [client, server] = Object.values(pair)

      // ✅ Accept with hibernation support
      // Tags help identify/group connections
      const userId = url.searchParams.get('userId') ?? 'anonymous'
      this.ctx.acceptWebSocket(server, [userId, 'all'])

      return new Response(null, { status: 101, webSocket: client })
    }

    // HTTP endpoints still work
    if (url.pathname === '/stats') {
      const sockets = this.ctx.getWebSockets()
      return Response.json({ connections: sockets.length })
    }

    return new Response('Not Found', { status: 404 })
  }

  // ✅ Called when a WebSocket receives a message
  // DO wakes from hibernation, processes, then can hibernate again
  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    try {
      const data = JSON.parse(message as string)

      if (data.type === 'chat') {
        // Broadcast to all connections
        const sockets = this.ctx.getWebSockets()
        const outgoing = JSON.stringify({
          type: 'chat',
          userId: this.ctx.getWebSocketTags(ws)[0],
          message: data.message,
          timestamp: Date.now(),
        })

        for (const socket of sockets) {
          socket.send(outgoing)
        }
      }

      if (data.type === 'ping') {
        ws.send(JSON.stringify({ type: 'pong' }))
      }
    } catch (err) {
      ws.send(JSON.stringify({ type: 'error', message: 'Invalid message format' }))
    }
  }

  // ✅ Called when a WebSocket closes
  async webSocketClose(ws: WebSocket, code: number, reason: string, wasClean: boolean) {
    const tags = this.ctx.getWebSocketTags(ws)
    const userId = tags[0]

    // Notify others that user left
    const sockets = this.ctx.getWebSockets()
    for (const socket of sockets) {
      socket.send(JSON.stringify({
        type: 'user_left',
        userId,
      }))
    }
  }

  // ✅ Called on WebSocket error
  async webSocketError(ws: WebSocket, error: unknown) {
    console.error('WebSocket error:', error)
    ws.close(1011, 'Internal error')
  }
}

// ✅ Broadcast to specific tag group
async function broadcastToGroup(ctx: DurableObjectState, tag: string, message: string) {
  const sockets = ctx.getWebSockets(tag)
  for (const socket of sockets) {
    socket.send(message)
  }
}
```

**Cost comparison:**
- Non-hibernatable: Billed for ~$0.15/million requests + duration (expensive for long connections)
- Hibernatable: Billed only for message processing (~$0.15/million messages)

For 1000 users connected 8 hours sending 10 messages each:
- Non-hibernatable: ~$0.50 (8 hours × 1000 connections)
- Hibernatable: ~$0.0015 (10,000 messages)
