---
title: Doppler Platform Integrations
impact: HIGH
impactDescription: Sync secrets to deployment platforms
tags: doppler, integrations, vercel, cloudflare, aws, kubernetes
---

## Doppler Platform Integrations

### Vercel

**Dashboard Setup:**
1. Go to **Integrations** → **Add** → **Vercel**
2. Authorize Doppler to access Vercel
3. Map Doppler configs to Vercel environments:
   - `dev` → Development
   - `stg` → Preview
   - `prd` → Production

**Auto-Sync:** Secrets automatically sync when changed in Doppler.

**Manual Sync (CLI):**

```bash
# Export to Vercel project
doppler secrets download --no-file --format json | \
  jq -r 'to_entries[] | "\(.key)=\(.value)"' | \
  xargs -I {} vercel env add {} production
```

---

### Cloudflare Workers

**Bulk Sync:**

```bash
# Sync all secrets to Workers
doppler secrets --json | \
  jq -c 'with_entries(.value = .value.computed)' | \
  wrangler secret bulk
```

**Individual Secret:**

```bash
# Set single secret
doppler secrets get API_KEY --plain | wrangler secret put API_KEY
```

**In CI/CD:**

```yaml
- name: Sync to Cloudflare
  run: |
    doppler secrets --json | \
      jq -c 'with_entries(.value = .value.computed)' | \
      wrangler secret bulk
  env:
    DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}
    CLOUDFLARE_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
```

---

### AWS Lambda

**Update Function Environment:**

```bash
aws lambda update-function-configuration \
  --function-name my-function \
  --environment "$(doppler secrets download --no-file | jq '{Variables: .}')"
```

**In CI/CD:**

```yaml
- name: Sync to Lambda
  run: |
    aws lambda update-function-configuration \
      --function-name ${{ env.FUNCTION_NAME }} \
      --environment "$(doppler secrets download --no-file | jq '{Variables: .}')"
  env:
    DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

---

### AWS Secrets Manager

**Dashboard Sync:**
1. Go to **Integrations** → **AWS Secrets Manager**
2. Provide AWS credentials with Secrets Manager permissions
3. Map configs to AWS secrets

**Manual Sync:**

```bash
# Create/update AWS secret
doppler secrets download --no-file --format json | \
  aws secretsmanager put-secret-value \
    --secret-id my-app/production \
    --secret-string file:///dev/stdin
```

---

### Kubernetes

**Create/Update Secret:**

```bash
kubectl create secret generic app-secrets \
  --save-config \
  --dry-run=client \
  --from-env-file <(doppler secrets download --no-file --format docker) \
  -o yaml | kubectl apply -f -
```

**With Namespace:**

```bash
kubectl create secret generic app-secrets \
  --namespace production \
  --save-config \
  --dry-run=client \
  --from-env-file <(doppler secrets download --no-file --format docker) \
  -o yaml | kubectl apply -f -
```

**External Secrets Operator:**

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: doppler-backend
spec:
  provider:
    doppler:
      auth:
        secretRef:
          dopplerToken:
            name: doppler-token
            key: token
      project: backend-api
      config: prd
```

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: doppler-backend
    kind: SecretStore
  target:
    name: app-secrets
  dataFrom:
    - find:
        name:
          regexp: ".*"
```

---

### Docker

**Dockerfile:**

```dockerfile
# Install Doppler CLI
RUN curl -Ls https://cli.doppler.com/install.sh | sh

# Run with secrets
CMD ["doppler", "run", "--", "node", "server.js"]
```

**Docker Compose:**

```yaml
version: '3.8'
services:
  app:
    build: .
    environment:
      - DOPPLER_TOKEN=${DOPPLER_TOKEN}
    command: doppler run -- npm start
```

**Without Doppler in Container:**

```bash
# Generate .env and mount
doppler secrets download --no-file --format env > .env.production

docker run --env-file .env.production my-app
```

---

### Firebase Functions

**Sync Config:**

```bash
firebase functions:config:unset doppler && \
firebase functions:config:set doppler="$(doppler secrets download --no-file)"
```

**Access in Function:**

```javascript
const functions = require('firebase-functions')
const secrets = functions.config().doppler

exports.api = functions.https.onRequest((req, res) => {
  const apiKey = secrets.API_KEY
  // ...
})
```

---

### Terraform

```hcl
data "doppler_secrets" "this" {
  project = "backend-api"
  config  = "prd"
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = jsonencode(data.doppler_secrets.this.map)
}
```

---

### Railway

**Dashboard Sync:**
1. Go to **Integrations** → **Railway**
2. Connect Railway account
3. Map Doppler configs to Railway environments

Secrets auto-sync when changed.

---

### Fly.io

```bash
# Sync secrets to Fly app
doppler secrets download --no-file --format env | \
  xargs flyctl secrets set
```
