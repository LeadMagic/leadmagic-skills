---
name: wrangler
description: Best practices for using Wrangler CLI to develop, test, and deploy Cloudflare Workers. Use when configuring wrangler.toml/wrangler.jsonc, running local development, deploying Workers, or managing environments. Triggers on "wrangler config", "deploy worker", "local development", "wrangler.toml", "wrangler.jsonc".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "2.1.0"
  context7: cloudflare/workers-sdk
---

# Wrangler Best Practices

Comprehensive guide for using Wrangler to manage Cloudflare Workers development and deployment.

## What's New (2025)

- **wrangler.jsonc** - JSON with comments is now **recommended** over wrangler.toml
- **Automatic provisioning** - KV, R2, D1 created automatically on deploy (no IDs needed)
- **JSON Schema** - Add `"$schema": "./node_modules/wrangler/config-schema.json"` for IDE support
- **Compatibility date 2025-01-01+** - Required for latest Node.js APIs

## When to Apply

Reference these guidelines when:
- Setting up wrangler.toml configuration
- Running local development with `wrangler dev`
- Deploying to staging and production
- Managing secrets and environment variables
- Configuring bindings (D1, R2, KV, Durable Objects)

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Configuration | CRITICAL | `config-` |
| 2 | Development | HIGH | `dev-` |
| 3 | Deployment | HIGH | `deploy-` |
| 4 | Environments | MEDIUM-HIGH | `env-` |
| 5 | Bindings Setup | MEDIUM | `bindings-` |

## Quick Reference

### 1. Configuration (CRITICAL)

- `config-compatibility-date` - Always set compatibility_date
- `config-main-entry` - Specify correct main entry point
- `config-name-conventions` - Follow naming conventions
- `config-account-id` - Set account_id for deployments
- `config-routes` - Configure routes properly

### 2. Development (HIGH)

- `dev-local-mode` - Use --local for offline development
- `dev-remote-mode` - Use remote mode for binding testing
- `dev-persist` - Persist local state between sessions
- `dev-inspector` - Use Chrome DevTools for debugging
- `dev-vars` - Use .dev.vars for local secrets

### 3. Deployment (HIGH)

- `deploy-environments` - Use environments for staging/production
- `deploy-secrets` - Never commit secrets, use wrangler secret
- `deploy-dry-run` - Use --dry-run before production deploys
- `deploy-tail` - Use wrangler tail for live debugging
- `deploy-versions` - Track deployment versions

### 4. Environments (MEDIUM-HIGH)

- `env-separation` - Separate staging from production
- `env-inheritance` - Understand config inheritance
- `env-variables` - Environment-specific variables
- `env-routes` - Environment-specific routes

### 5. Bindings Setup (MEDIUM)

- `bindings-d1` - Configure D1 database bindings
- `bindings-r2` - Configure R2 bucket bindings
- `bindings-kv` - Configure KV namespace bindings
- `bindings-do` - Configure Durable Object bindings
- `bindings-services` - Configure service bindings

## Essential Configuration

### Basic wrangler.jsonc (Recommended)

```jsonc
// wrangler.jsonc
{
  "$schema": "./node_modules/wrangler/config-schema.json",
  "name": "my-worker",
  "main": "src/index.ts",
  "compatibility_date": "2025-01-01",
  "compatibility_flags": ["nodejs_compat"],
  "observability": {
    "enabled": true
  }
}
```

### Basic wrangler.toml

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2025-01-01"
compatibility_flags = ["nodejs_compat"]

[observability]
enabled = true

# Build configuration
[build]
command = "npm run build"

# Development
[dev]
port = 8787
local_protocol = "http"

# Variables (non-sensitive)
[vars]
ENVIRONMENT = "development"
API_VERSION = "v1"

# KV Namespace
[[kv_namespaces]]
binding = "CACHE"
id = "abc123"
preview_id = "def456"

# D1 Database
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "abc123"

# R2 Bucket
[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"

# Durable Objects
[[durable_objects.bindings]]
name = "COUNTER"
class_name = "Counter"

[[migrations]]
tag = "v1"
new_classes = ["Counter"]
```

### Multi-Environment Setup

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2025-01-01"
compatibility_flags = ["nodejs_compat"]

# Shared KV
[[kv_namespaces]]
binding = "CACHE"
id = "prod-kv-id"

# Production (default)
[vars]
ENVIRONMENT = "production"

# Staging environment
[env.staging]
name = "my-worker-staging"
vars = { ENVIRONMENT = "staging" }

[[env.staging.kv_namespaces]]
binding = "CACHE"
id = "staging-kv-id"

# Preview environment
[env.preview]
name = "my-worker-preview"
vars = { ENVIRONMENT = "preview" }
```

### Local Development Secrets (.dev.vars)

```bash
# .dev.vars - DO NOT COMMIT
API_KEY=sk-test-xxxxx
DATABASE_URL=postgres://localhost:5432/dev
JWT_SECRET=local-dev-secret
```

## Common Commands

```bash
# Development
wrangler dev                    # Start dev server (remote mode)
wrangler dev --local           # Start dev server (local mode)
wrangler dev --persist         # Persist state between restarts

# Deployment
wrangler deploy                # Deploy to production
wrangler deploy --env staging  # Deploy to staging
wrangler deploy --dry-run      # Preview without deploying

# Secrets
wrangler secret put API_KEY              # Add secret
wrangler secret put API_KEY --env staging # Add to staging
wrangler secret list                      # List secrets

# Database (D1)
wrangler d1 create my-database           # Create database
wrangler d1 execute DB --local --file=schema.sql  # Run SQL locally
wrangler d1 execute DB --file=schema.sql # Run SQL remotely

# Storage (R2) - New bucket commands in 2024-2025
wrangler r2 bucket create my-bucket      # Create bucket
wrangler r2 bucket info my-bucket        # View bucket info (NEW)
wrangler r2 bucket dev-url enable my-bucket  # Enable r2.dev URL (NEW)
wrangler r2 bucket domain add my-bucket  # Add custom domain (NEW)
wrangler r2 bucket lifecycle list my-bucket  # List lifecycle rules (NEW)

# KV
wrangler kv namespace create CACHE       # Create namespace
wrangler kv key put --binding=CACHE key "value"

# Debugging
wrangler tail                  # Stream live logs
wrangler tail --env staging    # Tail staging logs

# Types
wrangler types                 # Generate TypeScript types
```

## Project Structure

```
my-worker/
├── src/
│   ├── index.ts          # Main entry
│   └── ...
├── wrangler.toml         # Configuration
├── .dev.vars             # Local secrets (gitignored)
├── package.json
└── tsconfig.json
```

