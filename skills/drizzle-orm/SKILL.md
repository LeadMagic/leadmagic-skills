---
name: drizzle-orm
description: Drizzle ORM patterns for Cloudflare D1 and PostgreSQL. Use when defining schemas, writing queries, managing migrations. Triggers on "Drizzle", "ORM", "database schema", "migrations", "type-safe queries".
license: MIT
metadata:
  author: leadmagic
  version: "2.0.0"
---

# Drizzle ORM

Type-safe ORM patterns for Cloudflare D1 and PostgreSQL.

## Installation

```bash
# D1/SQLite
npm install drizzle-orm
npm install -D drizzle-kit

# PostgreSQL
npm install drizzle-orm postgres
npm install -D drizzle-kit
```

---

## Schema

See `rules/schema-patterns.md` for detailed patterns.

```typescript
// src/db/schema.ts
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core'

export const users = sqliteTable('users', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  email: text('email').notNull().unique(),
  name: text('name').notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' }).$defaultFn(() => new Date()),
})

export const posts = sqliteTable('posts', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  title: text('title').notNull(),
  authorId: text('author_id').notNull().references(() => users.id),
})

// Types
export type User = typeof users.$inferSelect
export type NewUser = typeof users.$inferInsert
```

### Relations

```typescript
import { relations } from 'drizzle-orm'

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}))

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, { fields: [posts.authorId], references: [users.id] }),
}))
```

---

## Database Client

### Cloudflare D1

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/d1'
import * as schema from './schema'

export function createDb(d1: D1Database) {
  return drizzle(d1, { schema })
}

// In Worker
const db = createDb(c.env.DB)
```

### PostgreSQL

```typescript
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

const client = postgres(process.env.DATABASE_URL!)
export const db = drizzle(client, { schema })
```

---

## Queries

See `rules/query-patterns.md` for detailed patterns.

```typescript
import { eq, and, desc } from 'drizzle-orm'

// Select
const users = await db.select().from(users)
const user = await db.select().from(users).where(eq(users.id, id))

// With relations
const postsWithAuthor = await db.query.posts.findMany({
  with: { author: true },
})

// Insert
const [newUser] = await db.insert(users).values({ email, name }).returning()

// Update
await db.update(users).set({ name }).where(eq(users.id, id))

// Delete
await db.delete(posts).where(eq(posts.id, id))
```

### D1 Batch API

```typescript
const results = await db.batch([
  db.insert(users).values({ email: 'a@test.com', name: 'A' }),
  db.insert(users).values({ email: 'b@test.com', name: 'B' }),
])
```

---

## Migrations

```typescript
// drizzle.config.ts
import type { Config } from 'drizzle-kit'

export default {
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'sqlite',
} satisfies Config
```

```bash
# Generate migration
npx drizzle-kit generate

# Apply to D1 (local)
npx wrangler d1 migrations apply DB --local

# Apply to D1 (remote)
npx wrangler d1 migrations apply DB --remote
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Not using Batch API (D1) | Use `db.batch([...])` for multiple ops |
| Forgetting prepared statements | Use `.prepare()` for repeated queries |
| Missing indexes | Add indexes on frequently queried columns |
| Exposing DB errors | Catch and return user-friendly errors |
| Confusing D1 vs DO SQL | D1 = serverless SQLite, DO = in-memory |

---

## Quick Reference

| Operation | Code |
|-----------|------|
| Select all | `db.select().from(table)` |
| Select where | `db.select().from(table).where(eq(col, val))` |
| With relations | `db.query.table.findMany({ with: { rel: true } })` |
| Insert | `db.insert(table).values({...}).returning()` |
| Update | `db.update(table).set({...}).where(eq(col, val))` |
| Delete | `db.delete(table).where(eq(col, val))` |
| Transaction | `db.transaction(async (tx) => {...})` |
| Batch (D1) | `db.batch([op1, op2, op3])` |
