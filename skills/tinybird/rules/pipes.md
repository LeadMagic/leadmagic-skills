---
title: Tinybird Pipe Patterns
impact: CRITICAL
impactDescription: SQL transformations and API endpoints
tags: tinybird, pipes, sql, api, endpoints
---

## Tinybird Pipe Patterns

### Basic API Endpoint

```sql
# pipes/get_events.pipe
DESCRIPTION Get events with filtering

NODE endpoint
SQL >
    %
    SELECT
        timestamp,
        user_id,
        event_type,
        page_url
    FROM events
    WHERE
        timestamp >= {{DateTime(start_date, '2024-01-01 00:00:00')}}
        AND timestamp < {{DateTime(end_date, '2025-01-01 00:00:00')}}
        {% if defined(user_id) %}
        AND user_id = {{String(user_id)}}
        {% end %}
        {% if defined(event_type) %}
        AND event_type = {{String(event_type)}}
        {% end %}
    ORDER BY timestamp DESC
    LIMIT {{Int32(limit, 100)}}
```

### Multi-Node Pipe (CTEs)

```sql
# pipes/user_analytics.pipe
DESCRIPTION User analytics with aggregations

NODE user_events
SQL >
    SELECT
        user_id,
        count() as total_events,
        uniq(session_id) as sessions,
        min(timestamp) as first_seen,
        max(timestamp) as last_seen
    FROM events
    WHERE user_id = {{String(user_id)}}
    GROUP BY user_id

NODE user_pages
SQL >
    SELECT
        user_id,
        page_url,
        count() as views
    FROM events
    WHERE user_id = {{String(user_id)}} AND event_type = 'page_view'
    GROUP BY user_id, page_url
    ORDER BY views DESC
    LIMIT 10

NODE endpoint
SQL >
    SELECT
        e.user_id,
        e.total_events,
        e.sessions,
        e.first_seen,
        e.last_seen,
        groupArray((p.page_url, p.views)) as top_pages
    FROM user_events e
    LEFT JOIN user_pages p ON e.user_id = p.user_id
    GROUP BY e.user_id, e.total_events, e.sessions, e.first_seen, e.last_seen
```

### Materialized View Pipe

```sql
# pipes/aggregate_hourly.pipe
DESCRIPTION Aggregate events by hour

NODE hourly_aggregation
SQL >
    SELECT
        toStartOfHour(timestamp) as hour,
        event_type,
        page_url,
        count() as event_count,
        uniq(user_id) as unique_users
    FROM events
    GROUP BY hour, event_type, page_url

TYPE materialized
DATASOURCE events_hourly_mv
```

### Copy Pipe (ETL)

```sql
# pipes/copy_to_warehouse.pipe
DESCRIPTION Copy processed data to warehouse table

NODE transform
SQL >
    SELECT
        toDate(timestamp) as date,
        user_id,
        event_type,
        count() as event_count
    FROM events
    WHERE timestamp >= now() - INTERVAL 1 DAY
    GROUP BY date, user_id, event_type

TYPE copy
DATASOURCE daily_aggregates
COPY_MODE replace
COPY_SCHEDULE @daily
```

---

## Template Parameters

### Basic Types

```sql
{{String(param_name, 'default_value')}}
{{Int32(param_name, 100)}}
{{Int64(param_name)}}
{{Float64(param_name, 0.0)}}
{{DateTime(param_name, '2024-01-01 00:00:00')}}
{{Date(param_name, '2024-01-01')}}
```

### Conditional Logic

```sql
{% if defined(param_name) %}
    AND column = {{String(param_name)}}
{% end %}

{% if param_name == 'value' %}
    -- do something
{% else %}
    -- do something else
{% end %}
```

### Array Parameters

```sql
-- For IN clauses
{% if defined(event_types) %}
    AND event_type IN ({{Array(event_types, 'String', '')}})
{% end %}
```

---

## Aggregation Functions

| Function | Description |
|----------|-------------|
| `count()` | Count rows |
| `uniq(col)` | Approximate unique count |
| `uniqExact(col)` | Exact unique count |
| `sum(col)` | Sum values |
| `avg(col)` | Average |
| `min(col)` / `max(col)` | Min/Max |
| `argMax(a, b)` | Value of `a` at max `b` |
| `groupArray(col)` | Collect into array |
| `quantile(0.95)(col)` | Percentile |
| `topK(10)(col)` | Top K values |

---

## Time Functions

```sql
-- Truncation
toStartOfMinute(timestamp)
toStartOfHour(timestamp)
toStartOfDay(timestamp)
toStartOfWeek(timestamp)
toStartOfMonth(timestamp)

-- Extraction
toYear(timestamp)
toMonth(timestamp)
toDayOfWeek(timestamp)
toHour(timestamp)

-- Arithmetic
timestamp + INTERVAL 1 DAY
timestamp - INTERVAL 7 DAY
dateDiff('day', start, end)
```

---

## Best Practices

1. **Use %** at start of SQL for template parameters
2. **Define defaults** for all parameters
3. **Use `defined()` checks** for optional filters
4. **Order by sorting key columns** for faster queries
5. **Materialize heavy aggregations** for real-time queries
6. **Limit results** - always include LIMIT clause
