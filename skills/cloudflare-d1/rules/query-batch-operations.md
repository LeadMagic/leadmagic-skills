---
title: Use batch() for Multiple Operations
impact: CRITICAL
impactDescription: Atomic transactions and reduced latency
tags: transactions, batch, performance
---

## Use batch() for Multiple Operations

D1's `batch()` executes multiple statements atomically - all succeed or all fail. Use it for transactions and multi-step operations.

**Incorrect (multiple round trips, no atomicity):**

```typescript
app.post('/transfer', async (c) => {
  const { fromId, toId, amount } = await c.req.json()

  // ❌ Multiple separate queries - not atomic
  // If second query fails, first already committed!
  await c.env.DB
    .prepare('UPDATE accounts SET balance = balance - ? WHERE id = ?')
    .bind(amount, fromId)
    .run()

  await c.env.DB
    .prepare('UPDATE accounts SET balance = balance + ? WHERE id = ?')
    .bind(amount, toId)
    .run()

  await c.env.DB
    .prepare('INSERT INTO transfers (from_id, to_id, amount) VALUES (?, ?, ?)')
    .bind(fromId, toId, amount)
    .run()

  return c.json({ success: true })
})
```

**Correct (atomic batch operation):**

```typescript
app.post('/transfer', async (c) => {
  const { fromId, toId, amount } = await c.req.json()

  // ✅ All statements execute atomically
  const results = await c.env.DB.batch([
    c.env.DB
      .prepare('UPDATE accounts SET balance = balance - ? WHERE id = ?')
      .bind(amount, fromId),
    c.env.DB
      .prepare('UPDATE accounts SET balance = balance + ? WHERE id = ?')
      .bind(amount, toId),
    c.env.DB
      .prepare('INSERT INTO transfers (from_id, to_id, amount, created_at) VALUES (?, ?, ?, ?)')
      .bind(fromId, toId, amount, Date.now()),
  ])

  // Check all succeeded
  const allSucceeded = results.every(r => r.success)

  return c.json({ success: allSucceeded })
})

// ✅ Batch insert multiple rows
app.post('/users/bulk', async (c) => {
  const { users } = await c.req.json<{ users: CreateUserInput[] }>()

  const statements = users.map(user =>
    c.env.DB
      .prepare('INSERT INTO users (email, name) VALUES (?, ?)')
      .bind(user.email, user.name)
  )

  const results = await c.env.DB.batch(statements)

  return c.json({
    inserted: results.filter(r => r.success).length,
    total: users.length,
  })
})

// ✅ Create with related records
app.post('/posts', async (c) => {
  const { title, content, tags } = await c.req.json()

  // First, insert the post and get its ID
  const insertPost = await c.env.DB
    .prepare('INSERT INTO posts (title, content) VALUES (?, ?)')
    .bind(title, content)
    .run()

  const postId = insertPost.meta.last_row_id

  // Then batch insert all tags
  if (tags.length > 0) {
    const tagStatements = tags.map((tag: string) =>
      c.env.DB
        .prepare('INSERT INTO post_tags (post_id, tag) VALUES (?, ?)')
        .bind(postId, tag)
    )

    await c.env.DB.batch(tagStatements)
  }

  return c.json({ id: postId }, 201)
})
```

**batch() guarantees:**
- All statements succeed or all fail (atomic)
- Single network round trip (faster)
- Maximum 100 statements per batch
