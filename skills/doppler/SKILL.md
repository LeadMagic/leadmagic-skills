---
name: doppler
description: Doppler secrets management for environment variables across all environments. Use when managing secrets, syncing to Vercel/Cloudflare/AWS, or injecting env vars. Triggers on "Doppler", "secrets management", "environment variables", "secret sync".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Doppler

SecretOps platform for managing secrets across all environments.

## CLI Installation

```bash
# macOS
brew install dopplerhq/cli/doppler

# Linux/WSL
curl -Ls https://cli.doppler.com/install.sh | sh

# npm (for CI/CD)
npm install -g doppler
```

## Authentication

```bash
# Interactive login
doppler login

# Service token (for CI/CD)
export DOPPLER_TOKEN="dp.st.xxx"
```

---

## Core Concepts

| Concept | Description |
|---------|-------------|
| **Project** | Container for related configs (e.g., `backend-api`) |
| **Config** | Environment-specific secrets (e.g., `dev`, `stg`, `prd`) |
| **Service Token** | Read-only token for a specific config |
| **Personal Token** | Full access token for a user |

---

## CLI Usage

### Setup Project

```bash
# Initialize in project directory
doppler setup

# Select project and config
doppler setup --project backend-api --config dev
```

### Run with Secrets

```bash
# Inject secrets as env vars
doppler run -- npm start
doppler run -- node server.js
doppler run -- python app.py

# Run multiple commands
doppler run --command="npm run build && npm run deploy"

# Specify project/config
doppler run --project backend-api --config prd -- npm start
```

### Manage Secrets

```bash
# List secrets
doppler secrets

# Get specific secret
doppler secrets get DATABASE_URL

# Set secret
doppler secrets set API_KEY=sk_live_xxx

# Set multiple
doppler secrets set API_KEY=xxx SECRET_KEY=yyy

# Delete secret
doppler secrets delete OLD_KEY

# Download as file
doppler secrets download --no-file --format env > .env
doppler secrets download --no-file --format json > secrets.json
```

---

## Node.js Integration

### Using doppler run (Recommended)

```bash
# package.json
{
  "scripts": {
    "dev": "doppler run -- next dev",
    "start": "doppler run -- node server.js",
    "build": "doppler run -- next build"
  }
}
```

```typescript
// Access secrets as normal env vars
const apiKey = process.env.API_KEY
const databaseUrl = process.env.DATABASE_URL
```

### SDK (Programmatic Access)

```bash
npm install @dopplerhq/node-sdk
```

```typescript
import DopplerSDK from '@dopplerhq/node-sdk'

const doppler = new DopplerSDK({
  accessToken: process.env.DOPPLER_TOKEN,
})

// List projects
const projects = await doppler.projects.list()

// Get secrets
const secrets = await doppler.secrets.list({
  project: 'backend-api',
  config: 'prd',
})

// Get specific secret
const secret = await doppler.secrets.get({
  project: 'backend-api',
  config: 'prd',
  name: 'DATABASE_URL',
})
```

### Fetch Secrets Directly

```typescript
// For bootstrapping before app starts
import { execSync } from 'child_process'

function fetchSecrets(): Record<string, string> {
  try {
    return JSON.parse(
      execSync('doppler secrets download --no-file --format json').toString()
    )
  } catch (error) {
    console.error('Failed to fetch Doppler secrets')
    process.exit(1)
  }
}

const secrets = fetchSecrets()
```

---

## Platform Integrations

See `rules/integrations.md` for detailed patterns.

### Vercel

1. Connect in Doppler dashboard: **Integrations** → **Vercel**
2. Select project and configs to sync
3. Secrets auto-sync on change

### Cloudflare Workers

```bash
# Sync to Workers
doppler secrets --json | jq -c 'with_entries(.value = .value.computed)' | wrangler secret bulk
```

### AWS Lambda

```bash
aws lambda update-function-configuration \
  --function-name $FUNCTION_NAME \
  --environment "$(doppler secrets download --no-file | jq '{Variables: .}')"
```

### Kubernetes

```bash
kubectl create secret generic app-secrets \
  --save-config \
  --dry-run=client \
  --from-env-file <(doppler secrets download --no-file --format docker) \
  -o yaml | kubectl apply -f -
```

---

## GitHub Actions

See `rules/ci-cd.md` for detailed patterns.

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dopplerhq/cli-action@v3

      - name: Build and Deploy
        run: doppler run -- npm run deploy
        env:
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}
```

---

## Service Tokens

Create read-only tokens for specific configs:

```bash
# Create token
doppler configs tokens create \
  --project backend-api \
  --config prd \
  --name "Production Deploy"

# Revoke token
doppler configs tokens revoke \
  --project backend-api \
  --config prd \
  --slug token-slug
```

### Token Scopes

| Token Type | Scope | Use Case |
|------------|-------|----------|
| Personal | All projects | Development |
| Service | Single config | CI/CD, production |
| CLI | Full access | Local dev |

---

## API Reference

```bash
# Base URL
https://api.doppler.com

# Authentication header
Authorization: Bearer dp.xx.yyy
```

### Get Secrets

```bash
curl "https://api.doppler.com/v3/configs/config/secrets?project=backend-api&config=prd" \
  -H "Authorization: Bearer $DOPPLER_TOKEN"
```

### Get Single Secret

```bash
curl "https://api.doppler.com/v3/configs/config/secret?project=backend-api&config=prd&name=API_KEY" \
  -H "Authorization: Bearer $DOPPLER_TOKEN"
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Committing .env files | Use `doppler run` instead |
| Hardcoding tokens | Use `DOPPLER_TOKEN` env var |
| Using personal token in CI | Create service token per config |
| Not running `doppler setup` | Run in project root first |
| Mixing configs | Use `--project` and `--config` flags |

---

## Quick Reference

| Task | Command |
|------|---------|
| Login | `doppler login` |
| Setup project | `doppler setup` |
| Run with secrets | `doppler run -- <cmd>` |
| List secrets | `doppler secrets` |
| Set secret | `doppler secrets set KEY=value` |
| Download .env | `doppler secrets download --no-file --format env` |
| Create token | `doppler configs tokens create` |
