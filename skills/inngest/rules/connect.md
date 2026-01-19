# Connect (SDK v3.0+)

Deploy Inngest functions without HTTP endpoints using WebSocket connections.

## When to Use

- Long-running processes (containers, VMs)
- Edge functions without HTTP
- Self-hosted infrastructure
- Behind firewalls without ingress

## Basic Setup

```typescript
import { connect } from 'inngest'
import { inngest } from './client'
import { functions } from './functions'

const connection = await connect({
  apps: [
    {
      client: inngest,
      functions,
    },
  ],
})

// Connection is now established via WebSocket
console.log('Connected to Inngest')

// Graceful shutdown
process.on('SIGTERM', async () => {
  await connection.close()
})
```

## Custom Gateway Endpoint

For self-hosted Inngest or custom routing:

```typescript
const connection = await connect({
  apps: [...],
  rewriteGatewayEndpoint: (url) => {
    // ex. "wss://gw2.connect.inngest.com/v0/connect"
    
    // Only rewrite in production
    if (!process.env.INNGEST_DEV) {
      const clusterUrl = new URL(url)
      clusterUrl.host = 'my-cluster-host:8289'
      return clusterUrl.toString()
    }
    
    return url
  },
})
```

## Docker/Container Example

```typescript
// index.ts - Container entrypoint
import { connect } from 'inngest'
import { inngest, functions } from './inngest'

async function main() {
  console.log('Starting Inngest Connect...')

  const connection = await connect({
    apps: [{ client: inngest, functions }],
  })

  console.log('Connected to Inngest gateway')

  // Keep process alive
  process.on('SIGTERM', async () => {
    console.log('Shutting down...')
    await connection.close()
    process.exit(0)
  })
}

main().catch(console.error)
```

## Comparison: serve vs connect

| Feature | serve() | connect() |
|---------|---------|-----------|
| Transport | HTTP webhooks | WebSocket |
| Requires ingress | Yes | No |
| Use case | Serverless, HTTP APIs | Containers, Edge |
| Setup | API route handler | Standalone script |

## Notes

- Connect maintains a persistent WebSocket connection
- Functions execute in your environment, not Inngest's
- Supports all step.* functions
- Works with dev server for local development
