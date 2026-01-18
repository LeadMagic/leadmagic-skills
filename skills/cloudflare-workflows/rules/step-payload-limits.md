---
title: Keep Step Payloads Under 1 MiB
impact: CRITICAL
impactDescription: Steps returning >1 MiB will fail causing workflow failure
tags: workflows, limits, payload, storage
---

## Keep Step Payloads Under 1 MiB

Step return values must be under 1 MiB. Store large data externally (R2, KV) and return only references.

**Incorrect (large payloads in steps):**

```typescript
export class DataProcessingWorkflow extends WorkflowEntrypoint<Env, Params> {
  async run(event: WorkflowEvent<Params>, step: WorkflowStep) {
    // ❌ Step returns large dataset - WILL FAIL if >1 MiB
    const allUsers = await step.do('fetch-all-users', async () => {
      const { results } = await this.env.DB
        .prepare('SELECT * FROM users')
        .all()
      return results // Could be megabytes of data!
    })
    
    // ❌ Processing returns large transformed data
    const processedData = await step.do('process-data', async () => {
      return allUsers.map(user => ({
        ...user,
        computed: heavyComputation(user),
        history: getUserHistory(user.id), // More data!
      }))
    })
    
    // ❌ Fetching large files into step return
    const fileContents = await step.do('fetch-file', async () => {
      const object = await this.env.BUCKET.get('large-file.json')
      return object?.text() // Could be huge!
    })
    
    return { processed: processedData.length }
  }
}
```

**Correct (store large data externally, return references):**

```typescript
export class DataProcessingWorkflow extends WorkflowEntrypoint<Env, Params> {
  async run(event: WorkflowEvent<Params>, step: WorkflowStep) {
    const { batchId } = event.payload
    
    // ✅ Step 1: Store large data in R2, return reference
    const dataRef = await step.do('fetch-and-store-users', async () => {
      const { results } = await this.env.DB
        .prepare('SELECT * FROM users')
        .all()
      
      // Store in R2
      const key = `workflows/${batchId}/users.json`
      await this.env.BUCKET.put(key, JSON.stringify(results))
      
      // Return only the reference (small)
      return { 
        key,
        count: results.length,
        fetchedAt: Date.now(),
      }
    })
    
    // ✅ Step 2: Process in chunks, store results externally
    const processedRef = await step.do('process-data', async () => {
      // Fetch from R2
      const object = await this.env.BUCKET.get(dataRef.key)
      const users = await object?.json() as User[]
      
      // Process
      const processed = users.map(user => ({
        id: user.id,
        computed: heavyComputation(user),
      }))
      
      // Store results back to R2
      const resultKey = `workflows/${batchId}/processed.json`
      await this.env.BUCKET.put(resultKey, JSON.stringify(processed))
      
      // Return reference only
      return {
        key: resultKey,
        count: processed.length,
      }
    })
    
    // ✅ Step 3: Return small summary
    return {
      batchId,
      usersProcessed: processedRef.count,
      resultsLocation: processedRef.key,
    }
  }
}

// ✅ For streaming large files, process in chunks
export class FileProcessingWorkflow extends WorkflowEntrypoint<Env, Params> {
  async run(event: WorkflowEvent<Params>, step: WorkflowStep) {
    const { fileKey } = event.payload
    
    // Get file metadata first
    const metadata = await step.do('get-metadata', async () => {
      const head = await this.env.BUCKET.head(fileKey)
      return {
        size: head?.size ?? 0,
        contentType: head?.httpMetadata?.contentType,
      }
    })
    
    // Process in chunks if large
    const chunkSize = 512 * 1024 // 512 KB chunks
    const numChunks = Math.ceil(metadata.size / chunkSize)
    
    for (let i = 0; i < numChunks; i++) {
      await step.do(`process-chunk-${i}`, async () => {
        const start = i * chunkSize
        const end = Math.min(start + chunkSize, metadata.size)
        
        const object = await this.env.BUCKET.get(fileKey, {
          range: { offset: start, length: end - start },
        })
        
        const chunk = await object?.arrayBuffer()
        await processChunk(chunk, i)
        
        // Return small status, not the data
        return { chunk: i, processed: true }
      })
    }
    
    return { 
      fileKey,
      chunksProcessed: numChunks,
    }
  }
}
```

**Payload size guidelines:**

| Data Type | Approach |
|-----------|----------|
| Database results | Paginate queries, store full results in R2/KV |
| File contents | Store in R2, pass key reference |
| API responses | Extract needed fields only, store raw in R2 |
| Computed results | Store in R2, return summary stats |
| IDs/references | Safe to return (small) |

**Step return size estimation:**
- Assume 1 character ≈ 1 byte for JSON
- 1 MiB ≈ 1,000,000 characters
- 10,000 user records with 50 fields each = ~5 MiB = ❌ TOO BIG
- 10,000 user IDs only = ~200 KB = ✅ OK
