---
title: Axiom APL Query Patterns
impact: HIGH
impactDescription: Query and analyze log data effectively
tags: axiom, apl, queries, analytics
---

## Axiom APL Query Patterns

APL (Axiom Processing Language) is a powerful query language for analyzing event data.

### Basic Structure

```apl
['dataset-name']
| where <condition>
| project <fields>
| summarize <aggregation> by <grouping>
| sort <field>
| limit <n>
```

---

## Filtering (where)

```apl
// Exact match
| where level == 'error'

// Not equal
| where status != 200

// Numeric comparison
| where duration_ms > 1000

// String contains
| where message contains 'timeout'

// String starts with
| where path startswith '/api/'

// Null check
| where isnotnull(user_id)

// Time filter
| where _time > ago(1h)
| where _time > datetime(2025-01-15)
| where _time between (ago(24h) .. now())

// Multiple conditions
| where level == 'error' and service == 'api'
| where status >= 400 or duration_ms > 5000

// In list
| where status in (400, 401, 403, 404)
| where service in ('api', 'worker', 'cron')
```

---

## Projection (project)

```apl
// Select specific fields
| project _time, level, message, user_id

// Rename fields
| project timestamp = _time, severity = level

// Computed fields
| project _time, message, is_slow = duration_ms > 1000

// Exclude fields (project-away)
| project-away raw_body, headers
```

---

## Aggregation (summarize)

```apl
// Count
| summarize count()
| summarize total = count()

// Count with condition
| summarize errors = countif(level == 'error')

// Unique count
| summarize unique_users = dcount(user_id)

// Sum, avg, min, max
| summarize total_bytes = sum(bytes)
| summarize avg_duration = avg(duration_ms)
| summarize min_latency = min(latency_ms), max_latency = max(latency_ms)

// Percentiles
| summarize p50 = percentile(duration_ms, 50), p99 = percentile(duration_ms, 99)

// Group by
| summarize count() by level
| summarize count() by service, level
| summarize count() by bin(_time, 5m)

// Multiple aggregations
| summarize
    total = count(),
    errors = countif(level == 'error'),
    avg_duration = avg(duration_ms)
  by service
```

---

## Time Bucketing

```apl
// Fixed time buckets
| summarize count() by bin(_time, 1m)   // per minute
| summarize count() by bin(_time, 5m)   // 5 minutes
| summarize count() by bin(_time, 1h)   // hourly
| summarize count() by bin(_time, 1d)   // daily

// Time functions
| extend hour = hourofday(_time)
| extend day = dayofweek(_time)
| extend date = startofday(_time)
```

---

## Extending Data

```apl
// Add computed columns
| extend is_error = level == 'error'
| extend duration_sec = duration_ms / 1000.0
| extend error_rate = errors * 100.0 / total

// Extract from strings
| extend domain = extract('https?://([^/]+)', 1, url)

// Conditional
| extend severity = case(
    level == 'error', 'high',
    level == 'warn', 'medium',
    'low'
  )

// Parse JSON
| extend parsed = parse_json(properties)
| extend user_id = parsed.userId
```

---

## Sorting and Limiting

```apl
// Sort ascending
| sort by _time asc

// Sort descending
| sort by count_ desc

// Top N
| top 10 by count_
| top 5 by duration_ms desc

// Limit
| limit 100
| take 50
```

---

## Common Query Patterns

### Error Analysis

```apl
['logs']
| where _time > ago(24h)
| where level == 'error'
| summarize
    count = count(),
    first_seen = min(_time),
    last_seen = max(_time)
  by error_type, service
| sort by count desc
```

### Latency Percentiles

```apl
['logs']
| where _time > ago(1h)
| summarize
    p50 = percentile(duration_ms, 50),
    p90 = percentile(duration_ms, 90),
    p99 = percentile(duration_ms, 99)
  by endpoint
| sort by p99 desc
```

### Error Rate Over Time

```apl
['logs']
| where _time > ago(24h)
| summarize
    total = count(),
    errors = countif(status >= 500)
  by bin(_time, 1h)
| extend error_rate = errors * 100.0 / total
| project _time, error_rate
```

### User Activity

```apl
['logs']
| where _time > ago(7d)
| where isnotnull(user_id)
| summarize
    requests = count(),
    unique_endpoints = dcount(endpoint),
    last_seen = max(_time)
  by user_id
| sort by requests desc
| limit 100
```

### Slow Requests

```apl
['logs']
| where _time > ago(1h)
| where duration_ms > 1000
| project _time, endpoint, duration_ms, user_id, status
| sort by duration_ms desc
| limit 50
```

### Status Code Distribution

```apl
['logs']
| where _time > ago(24h)
| summarize count() by tostring(status)
| sort by count_ desc
```

---

## Time Ranges

```apl
// Relative
| where _time > ago(15m)   // last 15 minutes
| where _time > ago(1h)    // last hour
| where _time > ago(24h)   // last 24 hours
| where _time > ago(7d)    // last 7 days

// Absolute
| where _time > datetime(2025-01-15T00:00:00Z)
| where _time between (datetime(2025-01-14) .. datetime(2025-01-15))

// Start of period
| where _time > startofday(now())
| where _time > startofweek(now())
| where _time > startofmonth(now())
```
