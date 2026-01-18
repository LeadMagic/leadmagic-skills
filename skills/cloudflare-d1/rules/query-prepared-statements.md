---
title: Always Use Prepared Statements
impact: CRITICAL
impactDescription: Prevents SQL injection attacks
tags: security, sql, queries
---

## Always Use Prepared Statements

Never concatenate user input into SQL queries. Always use prepared statements with `.bind()`.

**Incorrect (SQL injection vulnerability):**

```typescript
app.get('/users', async (c) => {
  const search = c.req.query('search')

  // ❌ NEVER DO THIS - SQL injection vulnerability
  const query = `SELECT * FROM users WHERE name LIKE '%${search}%'`
  const { results } = await c.env.DB.prepare(query).all()

  return c.json(results)
})

app.delete('/users/:id', async (c) => {
  const id = c.req.param('id')

  // ❌ Even "safe" looking queries are vulnerable
  await c.env.DB.prepare(`DELETE FROM users WHERE id = '${id}'`).run()

  return c.json({ deleted: true })
})
```

**Correct (prepared statements with bind):**

```typescript
app.get('/users', async (c) => {
  const search = c.req.query('search') ?? ''

  // ✅ Use ? placeholders and .bind()
  const { results } = await c.env.DB
    .prepare('SELECT * FROM users WHERE name LIKE ?')
    .bind(`%${search}%`)
    .all<User>()

  return c.json(results)
})

app.delete('/users/:id', async (c) => {
  const id = c.req.param('id')

  // ✅ Bind all user input
  const { meta } = await c.env.DB
    .prepare('DELETE FROM users WHERE id = ?')
    .bind(id)
    .run()

  return c.json({ deleted: meta.changes > 0 })
})

// ✅ Multiple parameters
app.post('/users', async (c) => {
  const { email, name, role } = await c.req.json<CreateUserInput>()

  const { meta } = await c.env.DB
    .prepare('INSERT INTO users (email, name, role, created_at) VALUES (?, ?, ?, ?)')
    .bind(email, name, role, Date.now())
    .run()

  return c.json({ id: meta.last_row_id }, 201)
})

// ✅ IN clause with multiple values
app.post('/users/batch', async (c) => {
  const { ids } = await c.req.json<{ ids: string[] }>()

  // Create placeholders: ?, ?, ?
  const placeholders = ids.map(() => '?').join(', ')

  const { results } = await c.env.DB
    .prepare(`SELECT * FROM users WHERE id IN (${placeholders})`)
    .bind(...ids)
    .all<User>()

  return c.json(results)
})
```

**Why this matters:**

An attacker could send: `?search=' OR '1'='1' --`

With string concatenation:
```sql
SELECT * FROM users WHERE name LIKE '%' OR '1'='1' --%'
-- Returns ALL users!
```

With prepared statements:
```sql
SELECT * FROM users WHERE name LIKE '%'' OR ''1''=''1'' --%'
-- Safely searches for literal string, returns nothing
```
