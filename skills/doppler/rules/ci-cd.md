---
title: Doppler CI/CD Patterns
impact: HIGH
impactDescription: Secure secrets in CI/CD pipelines
tags: doppler, ci-cd, github-actions, gitlab, jenkins
---

## Doppler CI/CD Patterns

### GitHub Actions

**Basic Setup:**

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

      - name: Install Doppler CLI
        uses: dopplerhq/cli-action@v3

      - name: Build
        run: doppler run -- npm run build
        env:
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}

      - name: Deploy
        run: doppler run -- npm run deploy
        env:
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}
```

**Multiple Environments:**

```yaml
name: Deploy

on:
  push:
    branches: [main, develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dopplerhq/cli-action@v3

      - name: Set Doppler Config
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            echo "DOPPLER_CONFIG=prd" >> $GITHUB_ENV
          else
            echo "DOPPLER_CONFIG=stg" >> $GITHUB_ENV
          fi

      - name: Deploy
        run: doppler run --config ${{ env.DOPPLER_CONFIG }} -- npm run deploy
        env:
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}
```

**With Matrix:**

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, stg, prd]
    steps:
      - uses: actions/checkout@v4
      - uses: dopplerhq/cli-action@v3

      - name: Deploy to ${{ matrix.environment }}
        run: doppler run --config ${{ matrix.environment }} -- npm run deploy
        env:
          DOPPLER_TOKEN: ${{ secrets[format('DOPPLER_TOKEN_{0}', matrix.environment)] }}
```

**Download Secrets to File:**

```yaml
- name: Create .env file
  run: doppler secrets download --no-file --format env > .env
  env:
    DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}

- name: Build with .env
  run: npm run build
```

---

### GitLab CI

```yaml
stages:
  - build
  - deploy

variables:
  DOPPLER_TOKEN: $DOPPLER_TOKEN

before_script:
  - curl -Ls https://cli.doppler.com/install.sh | sh

build:
  stage: build
  script:
    - doppler run -- npm run build
  artifacts:
    paths:
      - dist/

deploy_staging:
  stage: deploy
  script:
    - doppler run --config stg -- npm run deploy
  environment:
    name: staging
  only:
    - develop

deploy_production:
  stage: deploy
  script:
    - doppler run --config prd -- npm run deploy
  environment:
    name: production
  only:
    - main
```

---

### CircleCI

```yaml
version: 2.1

orbs:
  doppler: doppler/cli@1.0.0

jobs:
  build:
    docker:
      - image: cimg/node:18
    steps:
      - checkout
      - doppler/install
      - run:
          name: Build
          command: doppler run -- npm run build
          environment:
            DOPPLER_TOKEN: $DOPPLER_TOKEN

  deploy:
    docker:
      - image: cimg/node:18
    steps:
      - checkout
      - doppler/install
      - run:
          name: Deploy
          command: doppler run -- npm run deploy
          environment:
            DOPPLER_TOKEN: $DOPPLER_TOKEN

workflows:
  build-deploy:
    jobs:
      - build
      - deploy:
          requires:
            - build
          filters:
            branches:
              only: main
```

---

### Jenkins

```groovy
pipeline {
    agent any

    environment {
        DOPPLER_TOKEN = credentials('doppler-token')
    }

    stages {
        stage('Install Doppler') {
            steps {
                sh 'curl -Ls https://cli.doppler.com/install.sh | sh'
            }
        }

        stage('Build') {
            steps {
                sh 'doppler run -- npm run build'
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'doppler run --config prd -- npm run deploy'
            }
        }
    }
}
```

---

### Service Token Best Practices

**Create Separate Tokens:**

```bash
# Token per environment
doppler configs tokens create --project backend --config dev --name "GitHub Actions Dev"
doppler configs tokens create --project backend --config stg --name "GitHub Actions Stg"
doppler configs tokens create --project backend --config prd --name "GitHub Actions Prd"
```

**Store in CI:**

| Platform | Secret Name |
|----------|-------------|
| GitHub | `DOPPLER_TOKEN` or `DOPPLER_TOKEN_PRD` |
| GitLab | `DOPPLER_TOKEN` (Variable) |
| CircleCI | `DOPPLER_TOKEN` (Context) |
| Jenkins | `doppler-token` (Credential) |

**Rotate Tokens:**

```bash
# Revoke old token
doppler configs tokens revoke --project backend --config prd --slug old-token-slug

# Create new token
doppler configs tokens create --project backend --config prd --name "GitHub Actions Prd v2"
```

---

### Caching Secrets (Advanced)

For faster builds, cache secrets between runs:

```yaml
- name: Cache Doppler Secrets
  uses: actions/cache@v4
  with:
    path: .env.doppler
    key: doppler-${{ hashFiles('doppler.yaml') }}-${{ github.sha }}
    restore-keys: |
      doppler-${{ hashFiles('doppler.yaml') }}-

- name: Fetch Secrets
  if: steps.cache.outputs.cache-hit != 'true'
  run: doppler secrets download --no-file --format env > .env.doppler
  env:
    DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}

- name: Build
  run: |
    set -a && source .env.doppler && set +a
    npm run build
```

---

### Debugging

```yaml
# List available secrets (names only)
- name: Debug Secrets
  run: doppler secrets --only-names
  env:
    DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}

# Verify config
- name: Verify Setup
  run: |
    doppler configure --all
    doppler secrets --only-names | head -5
  env:
    DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}
```
