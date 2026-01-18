---
title: Drizzle ORM Query Patterns
impact: HIGH
impactDescription: Type-safe queries and mutations
tags: drizzle, queries, database
---

## Drizzle ORM Query Patterns

### Basic Queries

```typescript
import { eq, and, or, like, desc, asc, count, sql } from 'drizzle-orm'
import { db } from './index'
import { users, posts } from './schema'

// Select all
const allUsers = await db.select().from(users)

// Select with conditions
const user = await db.select().from(users).where(eq(users.id, userId))

// Select specific columns
const emails = await db.select({ email: users.email }).from(users)

// Multiple conditions
const results = await db.select().from(posts).where(
  and(
    eq(posts.published, true),
    eq(posts.authorId, userId)
  )
)

// OR conditions
const results = await db.select().from(users).where(
  or(
    eq(users.role, 'admin'),
    eq(users.role, 'moderator')
  )
)

// LIKE search
const results = await db.select().from(users).where(
  like(users.name, '%john%')
)

// Order and limit
const recentPosts = await db.select()
  .from(posts)
  .orderBy(desc(posts.createdAt))
  .limit(10)
```

### Relational Queries

```typescript
// With relations
const postsWithAuthor = await db.query.posts.findMany({
  with: { author: true },
})

// Nested relations
const usersWithPosts = await db.query.users.findMany({
  with: {
    posts: {
      with: { comments: true },
      where: eq(posts.published, true),
      orderBy: desc(posts.createdAt),
      limit: 5,
    },
  },
})

// Find first
const user = await db.query.users.findFirst({
  where: eq(users.email, email),
  with: { posts: true },
})
```

### Mutations

```typescript
// Insert
const [newUser] = await db.insert(users).values({
  email: 'john@example.com',
  name: 'John Doe',
}).returning()

// Insert many
await db.insert(posts).values([
  { title: 'Post 1', content: '...', authorId },
  { title: 'Post 2', content: '...', authorId },
])

// Update
await db.update(users)
  .set({ name: 'Jane Doe' })
  .where(eq(users.id, userId))

// Update with returning
const [updated] = await db.update(posts)
  .set({ published: true })
  .where(eq(posts.id, postId))
  .returning()

// Delete
await db.delete(posts).where(eq(posts.id, postId))

// Upsert (on conflict)
await db.insert(users)
  .values({ id: 'abc', email: 'test@example.com', name: 'Test' })
  .onConflictDoUpdate({
    target: users.id,
    set: { name: 'Updated Name' },
  })
```

### Aggregations

```typescript
// Count
const [{ total }] = await db.select({ total: count() }).from(users)

// Count with condition
const [{ published }] = await db.select({ published: count() })
  .from(posts)
  .where(eq(posts.published, true))

// Group by
const postsByAuthor = await db.select({
  authorId: posts.authorId,
  count: count(),
}).from(posts).groupBy(posts.authorId)
```

### Transactions

```typescript
await db.transaction(async (tx) => {
  const [user] = await tx.insert(users).values({
    email: 'new@example.com',
    name: 'New User',
  }).returning()

  await tx.insert(posts).values({
    title: 'Welcome Post',
    content: 'Hello!',
    authorId: user.id,
  })
})
```

### D1 Batch API

```typescript
// Batch multiple operations (D1 specific)
const results = await db.batch([
  db.insert(users).values({ email: 'a@example.com', name: 'A' }),
  db.insert(users).values({ email: 'b@example.com', name: 'B' }),
  db.select().from(users),
])
```

### Prepared Statements

```typescript
const prepared = db
  .select()
  .from(users)
  .where(eq(users.id, sql.placeholder('id')))
  .prepare()

// Execute multiple times efficiently
const user1 = await prepared.execute({ id: '123' })
const user2 = await prepared.execute({ id: '456' })
```
