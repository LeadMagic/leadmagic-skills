---
name: tinybird
description: Tinybird real-time analytics platform. Use when building analytics APIs, event ingestion, real-time dashboards, or ClickHouse-powered data pipelines. Triggers on "Tinybird", "analytics", "real-time data", "ClickHouse", "data API", "event ingestion".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Tinybird

Real-time analytics platform for building data APIs with ClickHouse.

## Core Concepts

| Concept | Description |
|---------|-------------|
| **Data Source** | Table for storing data (ClickHouse table) |
| **Pipe** | SQL transformation, can be published as API |
| **Endpoint** | Published Pipe accessible via HTTP API |
| **Materialized View** | Pre-computed aggregations at ingestion |
| **Token** | Authentication for API access |

## CLI Setup

```bash
# Install Tinybird CLI
pip install tinybird-cli

# Login (creates ~/.tinyb with token)
tb login

# Initialize project
tb init

# Local development
tb local start
```

---

## Data Sources

See `rules/datasources.md` for detailed patterns.

### Basic Schema

```
# datasources/events.datasource
SCHEMA >
    `timestamp` DateTime `json:$.timestamp`,
    `user_id` String `json:$.user_id`,
    `event_type` String `json:$.event_type`,
    `properties` String `json:$.properties`

ENGINE "MergeTree"
ENGINE_SORTING_KEY "timestamp, user_id"
ENGINE_PARTITION_KEY "toYYYYMM(timestamp)"
```

### With Deduplication (ReplacingMergeTree)

```
# datasources/users.datasource
SCHEMA >
    `user_id` String `json:$.user_id`,
    `email` String `json:$.email`,
    `name` String `json:$.name`,
    `updated_at` DateTime `json:$.updated_at`

ENGINE "ReplacingMergeTree"
ENGINE_SORTING_KEY "user_id"
ENGINE_VER "updated_at"
```

---

## Pipes (SQL Transformations)

See `rules/pipes.md` for detailed patterns.

### API Endpoint

```sql
# pipes/top_pages.pipe
DESCRIPTION Get top pages by views

NODE endpoint
SQL >
    %
    SELECT
        page_url,
        count() as views,
        uniq(user_id) as unique_visitors
    FROM events
    WHERE
        event_type = 'page_view'
        AND timestamp >= {{DateTime(start_date, '2024-01-01 00:00:00')}}
        AND timestamp < {{DateTime(end_date, '2025-01-01 00:00:00')}}
        {% if defined(page_filter) %}
        AND page_url LIKE {{String(page_filter, '%')}}
        {% end %}
    GROUP BY page_url
    ORDER BY views DESC
    LIMIT {{Int32(limit, 10)}}
```

### Materialized View

```sql
# pipes/aggregate_events.pipe
DESCRIPTION Aggregate events hourly

NODE hourly_aggregation
SQL >
    SELECT
        toStartOfHour(timestamp) as hour,
        event_type,
        count() as event_count,
        uniq(user_id) as unique_users
    FROM events
    GROUP BY hour, event_type

TYPE materialized
DATASOURCE events_hourly_mv
```

---

## Data Ingestion

### Events API (Real-time)

```bash
# Single event
curl -X POST "https://api.tinybird.co/v0/events?name=events" \
  -H "Authorization: Bearer $TB_TOKEN" \
  -d '{"timestamp":"2024-01-15T10:00:00Z","user_id":"u123","event_type":"click"}'

# Batch (NDJSON)
curl -X POST "https://api.tinybird.co/v0/events?name=events" \
  -H "Authorization: Bearer $TB_TOKEN" \
  -d '{"timestamp":"2024-01-15T10:00:00Z","user_id":"u1","event_type":"click"}
{"timestamp":"2024-01-15T10:01:00Z","user_id":"u2","event_type":"view"}'
```

### Data Sources API (Bulk)

```bash
# From URL
curl -X POST "https://api.tinybird.co/v0/datasources?name=events&mode=append" \
  -H "Authorization: Bearer $TB_TOKEN" \
  -d '{"url":"https://example.com/data.csv"}'

# From file
curl -X POST "https://api.tinybird.co/v0/datasources?name=events&mode=append" \
  -H "Authorization: Bearer $TB_TOKEN" \
  -F "csv=@data.csv"
```

### CLI Ingestion

```bash
# Append from URL
tb datasource append events --url "https://example.com/data.parquet"

# Append from file
tb datasource append events --file data.csv
```

---

## Query API Endpoints

### JavaScript/TypeScript

```typescript
const TB_TOKEN = process.env.TINYBIRD_TOKEN!
const TB_HOST = 'https://api.tinybird.co'

// Query endpoint
async function getTopPages(startDate: string, limit = 10) {
  const params = new URLSearchParams({
    start_date: startDate,
    limit: limit.toString(),
  })

  const res = await fetch(
    `${TB_HOST}/v0/pipes/top_pages.json?${params}`,
    { headers: { Authorization: `Bearer ${TB_TOKEN}` } }
  )

  const { data } = await res.json()
  return data
}

// With error handling
async function queryTinybird<T>(pipe: string, params: Record<string, string>): Promise<T[]> {
  const url = new URL(`${TB_HOST}/v0/pipes/${pipe}.json`)
  Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v))

  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${TB_TOKEN}` },
  })

  if (!res.ok) {
    const error = await res.json()
    throw new Error(error.error || 'Tinybird query failed')
  }

  const { data } = await res.json()
  return data
}
```

### Next.js Server Component

```typescript
// app/analytics/page.tsx
async function getAnalytics() {
  const res = await fetch(
    `https://api.tinybird.co/v0/pipes/top_pages.json?limit=10`,
    {
      headers: { Authorization: `Bearer ${process.env.TINYBIRD_TOKEN}` },
      next: { revalidate: 60 }, // ISR: 60 seconds
    }
  )
  return res.json()
}

export default async function AnalyticsPage() {
  const { data } = await getAnalytics()
  return (
    <ul>
      {data.map((row) => (
        <li key={row.page_url}>{row.page_url}: {row.views} views</li>
      ))}
    </ul>
  )
}
```

### ClickHouse Client (Direct SQL)

```typescript
import { createClient } from '@clickhouse/client'

const client = createClient({
  url: 'https://clickhouse.tinybird.co',
  password: process.env.TINYBIRD_TOKEN,
})

const result = await client.query({
  query: `
    SELECT page_url, count() as views
    FROM events
    WHERE timestamp >= {start:DateTime}
    GROUP BY page_url
    ORDER BY views DESC
    LIMIT {limit:UInt32}
  `,
  query_params: {
    start: '2024-01-01 00:00:00',
    limit: 10,
  },
})

const data = await result.json()
```

---

## Authentication & Tokens

### Token Types

| Type | Use Case | Lifespan |
|------|----------|----------|
| **Admin** | CLI, backend | Permanent |
| **Read** | Query endpoints | Permanent |
| **Append** | Ingest data | Permanent |
| **JWT** | Frontend, per-user | Short-lived |

### Create Tokens

```bash
# Static token with scopes
tb token create my_read_token --scope PIPES:READ

# JWT with TTL and filtering
tb token create jwt frontend_jwt \
  --ttl 1h \
  --scope PIPES:READ \
  --resource top_pages \
  --fixed-params "org_id=acme"
```

### JWT for Multi-Tenant

```json
{
  "workspace_id": "<workspace_id>",
  "name": "user_token",
  "exp": 1705334400,
  "scopes": [
    {
      "type": "PIPES:READ",
      "resource": "analytics",
      "fixed_params": { "tenant_id": "tenant_123" }
    }
  ],
  "limits": { "rps": 10 }
}
```

---

## CLI Commands

```bash
# Development
tb local start              # Start local Tinybird
tb local stop               # Stop local Tinybird

# Deploy
tb push                     # Push changes to cloud
tb deploy                   # Deploy to production

# Data sources
tb datasource ls            # List data sources
tb datasource append <name> # Append data

# Pipes
tb pipe ls                  # List pipes
tb sql "SELECT * FROM events LIMIT 10"  # Run SQL

# Tokens
tb token ls                 # List tokens
tb token create <name>      # Create token
tb token copy <name>        # Copy to clipboard
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| No sorting key | Always set `ENGINE_SORTING_KEY` for query perf |
| Missing partition key | Add `ENGINE_PARTITION_KEY` for large tables |
| Using MergeTree for updates | Use `ReplacingMergeTree` + `ENGINE_VER` |
| Admin token in frontend | Use JWT with limited scope |
| No rate limiting | Add `limits.rps` to JWT tokens |
| Querying raw data | Use materialized views for aggregations |

---

## Quick Reference

| Task | Code/Command |
|------|--------------|
| Create data source | `.datasource` file + `tb push` |
| Create endpoint | `.pipe` file with SQL + `tb push` |
| Ingest event | `POST /v0/events?name=ds` |
| Ingest bulk | `POST /v0/datasources?name=ds&mode=append` |
| Query endpoint | `GET /v0/pipes/{pipe}.json?params` |
| Materialize | Add `TYPE materialized` to pipe node |
| Create token | `tb token create name --scope PIPES:READ` |
| Deploy | `tb deploy` |
