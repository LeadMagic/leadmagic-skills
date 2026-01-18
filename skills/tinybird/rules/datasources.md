---
title: Tinybird Data Source Patterns
impact: CRITICAL
impactDescription: Schema design and engine configuration
tags: tinybird, datasource, schema, clickhouse
---

## Tinybird Data Source Patterns

### Basic Data Source

```
# datasources/events.datasource
DESCRIPTION Events table for tracking user actions

SCHEMA >
    `timestamp` DateTime `json:$.timestamp`,
    `user_id` String `json:$.user_id`,
    `session_id` String `json:$.session_id`,
    `event_type` String `json:$.event_type`,
    `page_url` String `json:$.page_url`,
    `properties` String `json:$.properties`

ENGINE "MergeTree"
ENGINE_SORTING_KEY "timestamp, user_id, event_type"
ENGINE_PARTITION_KEY "toYYYYMM(timestamp)"
```

### With TTL (Auto-Delete Old Data)

```
# datasources/logs.datasource
DESCRIPTION Application logs with 90-day retention

SCHEMA >
    `timestamp` DateTime `json:$.timestamp`,
    `level` String `json:$.level`,
    `message` String `json:$.message`,
    `metadata` String `json:$.metadata`

ENGINE "MergeTree"
ENGINE_SORTING_KEY "timestamp, level"
ENGINE_PARTITION_KEY "toYYYYMM(timestamp)"
ENGINE_TTL "timestamp + INTERVAL 90 DAY"
```

### ReplacingMergeTree (Deduplication)

Use for data that may be updated (e.g., user profiles, order status).

```
# datasources/users.datasource
DESCRIPTION User profiles with deduplication

SCHEMA >
    `user_id` String `json:$.user_id`,
    `email` String `json:$.email`,
    `name` String `json:$.name`,
    `plan` String `json:$.plan`,
    `updated_at` DateTime `json:$.updated_at`

ENGINE "ReplacingMergeTree"
ENGINE_SORTING_KEY "user_id"
ENGINE_VER "updated_at"
```

### With Soft Deletes

```
# datasources/posts.datasource
DESCRIPTION Posts with soft delete support

SCHEMA >
    `post_id` Int64 `json:$.post_id`,
    `title` String `json:$.title`,
    `content` String `json:$.content`,
    `author_id` String `json:$.author_id`,
    `updated_at` DateTime `json:$.updated_at`,
    `_is_deleted` UInt8 `json:$._is_deleted`

ENGINE "ReplacingMergeTree"
ENGINE_SORTING_KEY "post_id"
ENGINE_VER "updated_at"
ENGINE_IS_DELETED "_is_deleted"
```

### AggregatingMergeTree (Pre-Aggregation)

For storing pre-aggregated metrics.

```
# datasources/page_stats_mv.datasource
DESCRIPTION Pre-aggregated page statistics

SCHEMA >
    `date` Date,
    `page_url` String,
    `views` AggregateFunction(count),
    `unique_users` AggregateFunction(uniq, String)

ENGINE "AggregatingMergeTree"
ENGINE_SORTING_KEY "date, page_url"
ENGINE_PARTITION_KEY "toYYYYMM(date)"
```

---

## Schema Column Types

| Type | Description | Example |
|------|-------------|---------|
| `String` | Variable-length string | `user_id`, `name` |
| `DateTime` | Timestamp (second precision) | `created_at` |
| `DateTime64(3)` | Timestamp (millisecond) | `timestamp` |
| `Date` | Date only | `event_date` |
| `Int32`, `Int64` | Signed integers | `count`, `id` |
| `UInt8`, `UInt32` | Unsigned integers | `is_deleted`, `views` |
| `Float32`, `Float64` | Floating point | `price`, `percentage` |
| `Nullable(T)` | Allow NULL values | `Nullable(String)` |
| `Array(T)` | Array of type T | `Array(String)` |

### JSON Path Mapping

```
`field_name` Type `json:$.path.to.field`
```

Examples:
```
`user_id` String `json:$.user.id`
`event_name` String `json:$.event.name`
`amount` Float64 `json:$.transaction.amount`
`tags` Array(String) `json:$.metadata.tags`
```

---

## Engine Selection

| Engine | Use Case |
|--------|----------|
| `MergeTree` | Append-only data (events, logs) |
| `ReplacingMergeTree` | Data with updates (users, orders) |
| `AggregatingMergeTree` | Materialized aggregations |
| `SummingMergeTree` | Auto-summing numeric columns |
| `CollapsingMergeTree` | Row-level versioning |

---

## Best Practices

1. **Always set ENGINE_SORTING_KEY** - Put high-cardinality columns first
2. **Partition large tables** - Use `toYYYYMM(date)` for time-series
3. **Use ReplacingMergeTree for updates** - With `ENGINE_VER` column
4. **Avoid Nullable when possible** - Use default values instead
5. **Add TTL for temporary data** - Auto-cleanup old records
