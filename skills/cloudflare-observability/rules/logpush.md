---
title: Cloudflare Logpush Patterns
impact: HIGH
impactDescription: Push Worker logs to external destinations
tags: cloudflare, logpush, logs, observability
---

## Cloudflare Logpush Patterns

Logpush sends Worker trace events to external destinations for long-term storage and analysis.

### Create Logpush Job

```bash
curl "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/logpush/jobs" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "workers-to-r2",
    "output_options": {
      "field_names": [
        "Event",
        "EventTimestampMs",
        "Outcome",
        "Exceptions",
        "Logs",
        "ScriptName",
        "ScriptVersion",
        "DispatchNamespace"
      ]
    },
    "destination_conf": "r2://logs-bucket/workers/{DATE}?account-id=$ACCOUNT_ID",
    "dataset": "workers_trace_events",
    "enabled": true
  }'
```

---

## Destination Configurations

### R2

```
r2://bucket-name/path/{DATE}?account-id=ACCOUNT_ID&access-key-id=KEY&secret-access-key=SECRET
```

### S3

```
s3://bucket-name/path/{DATE}?region=us-east-1&access-key-id=KEY&secret-access-key=SECRET
```

### Datadog

```
https://http-intake.logs.datadoghq.com/api/v2/logs?dd-api-key=API_KEY&ddsource=cloudflare
```

### Splunk

```
https://http-inputs-YOUR_INSTANCE.splunkcloud.com/services/collector/raw?channel=CHANNEL&header_Authorization=Splunk%20TOKEN
```

### Azure Blob Storage

```
https://ACCOUNT.blob.core.windows.net/CONTAINER/path/{DATE}?sas=TOKEN
```

### Google Cloud Storage

```
gs://bucket-name/path/{DATE}
```

---

## Available Fields

| Field | Type | Description |
|-------|------|-------------|
| `Event` | object | Event details (request info, etc.) |
| `EventTimestampMs` | number | Unix timestamp in milliseconds |
| `EventType` | string | fetch, scheduled, queue, etc. |
| `Outcome` | string | ok, exception, exceededCpu, etc. |
| `Exceptions` | array | Exception details if any |
| `Logs` | array | console.log/warn/error output |
| `ScriptName` | string | Worker script name |
| `ScriptVersion` | object | Deployment version info |
| `DispatchNamespace` | string | Workers for Platforms namespace |

### Request Event Fields (nested in Event)

```json
{
  "Event": {
    "request": {
      "url": "https://example.com/api",
      "method": "POST",
      "headers": {},
      "cf": {
        "country": "US",
        "city": "San Francisco"
      }
    },
    "response": {
      "status": 200
    }
  }
}
```

---

## Filters

### Only Errors

```json
{
  "filter": "{\"where\": {\"key\": \"Outcome\", \"operator\": \"eq\", \"value\": \"exception\"}}"
}
```

### Exclude Health Checks

```json
{
  "filter": "{\"where\": {\"key\": \"ScriptName\", \"operator\": \"!eq\", \"value\": \"health-check\"}}"
}
```

### Multiple Conditions

```json
{
  "filter": "{\"where\": {\"and\": [{\"key\": \"Outcome\", \"operator\": \"eq\", \"value\": \"exception\"}, {\"key\": \"ScriptName\", \"operator\": \"contains\", \"value\": \"api\"}]}}"
}
```

### Filter Operators

| Operator | Description |
|----------|-------------|
| `eq` | Equals |
| `!eq` | Not equals |
| `contains` | String contains |
| `!contains` | String does not contain |
| `gt` | Greater than |
| `lt` | Less than |
| `geq` | Greater than or equal |
| `leq` | Less than or equal |

---

## Manage Jobs

### List Jobs

```bash
curl "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/logpush/jobs" \
  -H "Authorization: Bearer $API_TOKEN"
```

### Get Job Details

```bash
curl "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/logpush/jobs/$JOB_ID" \
  -H "Authorization: Bearer $API_TOKEN"
```

### Update Job

```bash
curl -X PUT "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/logpush/jobs/$JOB_ID" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "enabled": false
  }'
```

### Delete Job

```bash
curl -X DELETE "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/logpush/jobs/$JOB_ID" \
  -H "Authorization: Bearer $API_TOKEN"
```

---

## Output Options

### Field Selection

```json
{
  "output_options": {
    "field_names": ["Event", "Outcome", "Logs", "ScriptName"]
  }
}
```

### Timestamp Format

```json
{
  "output_options": {
    "timestamp_format": "rfc3339"  // or "unix", "unixnano"
  }
}
```

### Sample Rate

```json
{
  "output_options": {
    "sample_rate": 0.1  // 10% of events
  }
}
```

---

## Best Practices

1. **Use R2 for cost efficiency** - Cheapest storage for Cloudflare logs
2. **Partition by date** - Use `{DATE}` in path for easy querying
3. **Filter early** - Reduce volume with Logpush filters
4. **Sample in production** - Use `sample_rate` for high-traffic Workers
5. **Monitor job health** - Check job status regularly
