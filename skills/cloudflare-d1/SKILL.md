---
name: cloudflare-d1
description: Best practices for using Cloudflare D1 SQLite database in Workers. Use when designing schemas, writing queries, performing migrations, or optimizing database performance. Triggers on "D1 database", "SQL query", "database schema", "migrations".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Cloudflare D1 Best Practices

Comprehensive guide for using Cloudflare D1 (SQLite at the edge) in Workers.

## When to Apply

Reference these guidelines when:
- Designing database schemas for D1
- Writing SQL queries in Workers
- Performing database migrations
- Optimizing query performance
- Integrating with Hono or other frameworks

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Query Patterns | CRITICAL | `query-` |

## Quick Reference

### 1. Query Patterns (CRITICAL)

- `query-prepared-statements` - Always use prepared statements (prevent SQL injection)
- `query-batch-operations` - Use batch() for multiple operations
- `integrate-error-handling` - Handle D1 errors properly
- `integrate-typing` - Type D1 results properly

## Essential Patterns

### Basic D1 Usage

```typescript
interface Env {
  DB: D1Database
}

// Prepared statement (ALWAYS use for user input)
const result = await env.DB
  .prepare('SELECT * FROM users WHERE id = ?')
  .bind(userId)
  .first<User>()

// All results
const { results } = await env.DB
  .prepare('SELECT * FROM users WHERE active = ?')
  .bind(true)
  .all<User>()

// Run (for INSERT, UPDATE, DELETE)
const { meta } = await env.DB
  .prepare('INSERT INTO users (email, name) VALUES (?, ?)')
  .bind(email, name)
  .run()

console.log(meta.last_row_id)  // Inserted row ID
console.log(meta.changes)      // Rows affected
```

### Batch Operations (Transactions)

```typescript
// Multiple operations in a single batch (atomic)
const results = await env.DB.batch([
  env.DB.prepare('INSERT INTO users (email) VALUES (?)').bind(email),
  env.DB.prepare('INSERT INTO audit_log (action) VALUES (?)').bind('user_created'),
  env.DB.prepare('UPDATE stats SET user_count = user_count + 1'),
])

// All succeed or all fail
```

### Hono Integration

```typescript
import { Hono } from 'hono'

type Bindings = {
  DB: D1Database
}

const app = new Hono<{ Bindings: Bindings }>()

app.get('/users/:id', async (c) => {
  const id = c.req.param('id')

  const user = await c.env.DB
    .prepare('SELECT id, email, name FROM users WHERE id = ?')
    .bind(id)
    .first<User>()

  if (!user) {
    return c.json({ error: 'User not found' }, 404)
  }

  return c.json(user)
})

app.post('/users', async (c) => {
  const { email, name } = await c.req.json<CreateUserInput>()

  const { meta } = await c.env.DB
    .prepare('INSERT INTO users (email, name) VALUES (?, ?)')
    .bind(email, name)
    .run()

  return c.json({ id: meta.last_row_id }, 201)
})
```

### Drizzle ORM Integration

```typescript
import { drizzle } from 'drizzle-orm/d1'
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core'
import { eq } from 'drizzle-orm'

// Schema definition
export const users = sqliteTable('users', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  email: text('email').notNull().unique(),
  name: text('name').notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' })
    .notNull()
    .$defaultFn(() => new Date()),
})

// Usage in Worker
const db = drizzle(env.DB)

// Type-safe queries
const user = await db
  .select()
  .from(users)
  .where(eq(users.id, userId))
  .get()

// Insert
await db.insert(users).values({
  email: 'user@example.com',
  name: 'John Doe',
})
```

### Schema Example

```sql
-- migrations/0001_initial.sql
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (unixepoch()),
  updated_at INTEGER NOT NULL DEFAULT (unixepoch())
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

CREATE TABLE IF NOT EXISTS posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT,
  published INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL DEFAULT (unixepoch())
);

CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_published ON posts(published);
```

### Error Handling

```typescript
async function safeQuery<T>(
  db: D1Database,
  query: string,
  params: unknown[] = []
): Promise<{ data: T | null; error: string | null }> {
  try {
    const stmt = db.prepare(query)
    const result = await stmt.bind(...params).first<T>()
    return { data: result, error: null }
  } catch (e) {
    const error = e instanceof Error ? e.message : 'Unknown database error'
    console.error('D1 Error:', error)
    return { data: null, error }
  }
}
```

## D1 Limits

| Resource | Limit |
|----------|-------|
| Database size | 10GB |
| Max rows per table | No limit (storage bound) |
| Max query result size | 20MB |
| Max bound parameters | 100 |
| Max batch statements | 100 |

## Wrangler Commands

```bash
# Create database
wrangler d1 create my-database

# Execute SQL locally
wrangler d1 execute DB --local --file=migrations/0001_initial.sql

# Execute SQL remotely
wrangler d1 execute DB --file=migrations/0001_initial.sql

# Interactive SQL shell
wrangler d1 execute DB --local --command="SELECT * FROM users"

# Export database
wrangler d1 export DB --output=backup.sql
```

