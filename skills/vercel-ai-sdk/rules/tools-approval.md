---
title: Use needsApproval for Dangerous Operations
impact: CRITICAL
impactDescription: Prevents unintended destructive operations
tags: tools, security, approval, safety
---

## Use needsApproval for Dangerous Operations

Tools that modify state, delete data, or perform irreversible actions should require human approval before execution. Use the `needsApproval` flag.

**Incorrect (dangerous operations without approval):**

```typescript
import { tool } from 'ai'
import { z } from 'zod'

// DANGEROUS: Auto-executes file deletion!
const deleteFilesTool = tool({
  description: 'Delete files from the system',
  parameters: z.object({
    paths: z.array(z.string()),
    force: z.boolean().default(false),
  }),
  execute: async ({ paths, force }) => {
    // Executes immediately without user confirmation
    for (const path of paths) {
      await fs.rm(path, { force })
    }
    return { deleted: paths }
  },
})

// DANGEROUS: Auto-executes database mutations!
const updateUserTool = tool({
  description: 'Update user data',
  parameters: z.object({
    userId: z.string(),
    data: z.record(z.unknown()),
  }),
  execute: async ({ userId, data }) => {
    // Could overwrite critical user data
    await db.users.update(userId, data)
    return { success: true }
  },
})
```

**Correct (with approval for dangerous operations):**

```typescript
import { tool } from 'ai'
import { z } from 'zod'

// Safe: Read-only operations don't need approval
const readFileTool = tool({
  description: 'Read a file from the system',
  parameters: z.object({
    path: z.string(),
  }),
  needsApproval: false, // Explicitly safe
  execute: async ({ path }) => {
    const content = await fs.readFile(path, 'utf-8')
    return { content, path }
  },
})

// Requires approval: Destructive operation
const deleteFilesTool = tool({
  description: 'Delete files from the system',
  parameters: z.object({
    paths: z.array(z.string()),
    force: z.boolean().default(false),
  }),
  needsApproval: true, // Requires human confirmation
  execute: async ({ paths, force }) => {
    // Only runs after user approves
    const deleted: string[] = []
    for (const path of paths) {
      await fs.rm(path, { force })
      deleted.push(path)
    }
    return { deleted, count: deleted.length }
  },
})

// Requires approval: Modifies user data
const updateUserTool = tool({
  description: 'Update user profile data',
  parameters: z.object({
    userId: z.string(),
    data: z.object({
      name: z.string().optional(),
      email: z.string().email().optional(),
      role: z.enum(['user', 'admin']).optional(),
    }),
  }),
  needsApproval: true, // Requires human confirmation
  execute: async ({ userId, data }) => {
    const updated = await db.users.update(userId, data)
    return { success: true, updated }
  },
})

// Requires approval: External API calls with side effects
const sendEmailTool = tool({
  description: 'Send an email to a user',
  parameters: z.object({
    to: z.string().email(),
    subject: z.string(),
    body: z.string(),
  }),
  needsApproval: true, // Can't undo sending an email
  execute: async ({ to, subject, body }) => {
    await emailService.send({ to, subject, body })
    return { sent: true, to }
  },
})
```

Guidelines for when to require approval:
- ✅ Delete operations (files, records, resources)
- ✅ Update operations (user data, settings)
- ✅ External communications (emails, notifications)
- ✅ Financial operations (payments, transfers)
- ✅ Permission changes (roles, access)
- ❌ Read-only operations (fetch, search, list)
- ❌ Idempotent operations (GET requests)
