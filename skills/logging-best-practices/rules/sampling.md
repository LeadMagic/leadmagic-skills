---
title: Log Sampling Strategies
impact: HIGH
impactDescription: Control costs while keeping important events
tags: logging, sampling, tail-sampling, observability, costs
---

## Log Sampling Strategies

At scale, storing 100% of logs is expensive and unnecessary. Sampling keeps costs manageable while ensuring you never lose important events.

### The Sampling Trap

**Naive random sampling is dangerous:**

```
10,000 requests/second
1 error (the one you need to debug)
1% random sampling = 99% chance you lose the error
```

---

## Tail Sampling

Make sampling decisions **after** the request completes, based on outcome.

### Decision Function

```typescript
interface WideEvent {
  status_code: number
  duration_ms: number
  error?: { type: string }
  user?: { subscription: string }
  feature_flags?: Record<string, boolean>
}

function shouldSample(event: WideEvent): boolean {
  // ALWAYS keep errors
  if (event.status_code >= 500) return true
  if (event.status_code >= 400) return true  // Client errors too
  if (event.error) return true

  // ALWAYS keep slow requests (above p99)
  if (event.duration_ms > 2000) return true

  // ALWAYS keep VIP users
  if (event.user?.subscription === 'enterprise') return true

  // ALWAYS keep specific user IDs (debugging)
  if (DEBUG_USER_IDS.includes(event.user?.id)) return true

  // ALWAYS keep feature flag rollouts
  if (event.feature_flags?.new_checkout_flow) return true
  if (event.feature_flags?.experimental_feature) return true

  // ALWAYS keep specific paths (critical flows)
  if (CRITICAL_PATHS.includes(event.request?.path)) return true

  // Random sample the rest
  return Math.random() < 0.05  // 5%
}
```

### Sampling Rules Table

| Condition | Sample Rate | Rationale |
|-----------|-------------|-----------|
| 5xx errors | 100% | Always debug server errors |
| 4xx errors | 100% | Client issues matter |
| Slow (>p99) | 100% | Performance investigation |
| Enterprise users | 100% | VIP support |
| Debug users | 100% | Active investigation |
| Feature flags | 100% | Rollout monitoring |
| Critical paths | 100% | Checkout, auth, payments |
| Normal success | 1-5% | Cost control |

---

## Head vs Tail Sampling

### Head Sampling (Decision at Start)

```typescript
// ❌ Less useful - decision before you know outcome
function headSample(request: Request): boolean {
  // You don't know if this will error yet
  return Math.random() < 0.10
}
```

**Problems:**
- Can't prioritize errors (don't know yet)
- Can't prioritize slow requests (don't know yet)
- Blind random sampling

### Tail Sampling (Decision at End)

```typescript
// ✅ Better - decision after outcome known
function tailSample(event: WideEvent): boolean {
  // Now you know everything
  if (event.status_code >= 500) return true
  if (event.duration_ms > 2000) return true
  return Math.random() < 0.05
}
```

**Benefits:**
- Keep all errors
- Keep all slow requests
- Smart sampling based on actual outcome

---

## Distributed Tail Sampling

For microservices, ensure correlated events are sampled together.

### Propagate Sampling Decision

```typescript
// Service A makes decision
const event = createWideEvent(req)
// ... process request ...
const shouldKeep = shouldSample(event)

// Pass decision to downstream services
const response = await fetch(serviceB, {
  headers: {
    'x-trace-id': event.trace_id,
    'x-sample-decision': shouldKeep ? 'keep' : 'drop',
  }
})
```

### Respect Upstream Decision

```typescript
// Service B respects upstream decision
function shouldSample(event: WideEvent, req: Request): boolean {
  const upstreamDecision = req.headers.get('x-sample-decision')

  // If upstream said keep, we keep
  if (upstreamDecision === 'keep') return true

  // Otherwise, apply our own rules
  // (might promote to 'keep' if we error)
  if (event.status_code >= 500) return true

  // Follow upstream drop decision
  if (upstreamDecision === 'drop') return false

  // No upstream decision, apply local rules
  return Math.random() < 0.05
}
```

---

## Cost Estimation

```
Events/day = requests/sec × 60 × 60 × 24
           = 10,000 × 86,400
           = 864,000,000 events/day

With 5% sampling:
           = 43,200,000 events/day (sampled)
           + ~200,000 errors (100%)
           + ~500,000 slow (100%)
           ≈ 44,000,000 events/day stored

Storage (1KB/event):
           = 44 GB/day
           = 1.3 TB/month
```

---

## Dynamic Sampling Rates

Adjust sampling based on current conditions:

```typescript
class DynamicSampler {
  private errorRate = 0
  private baseRate = 0.05

  updateErrorRate(recentErrors: number, recentTotal: number) {
    this.errorRate = recentErrors / recentTotal
  }

  getSampleRate(): number {
    // Increase sampling when error rate spikes
    if (this.errorRate > 0.05) return 0.50  // 50% during incidents
    if (this.errorRate > 0.01) return 0.20  // 20% elevated errors
    return this.baseRate                     // 5% normal
  }

  shouldSample(event: WideEvent): boolean {
    if (event.status_code >= 500) return true
    return Math.random() < this.getSampleRate()
  }
}
```

---

## Implementation Checklist

- [ ] Implement tail sampling (not head)
- [ ] Always keep 5xx errors
- [ ] Always keep 4xx errors
- [ ] Always keep slow requests (>p99)
- [ ] Always keep VIP users
- [ ] Always keep feature flag traffic
- [ ] Propagate decisions across services
- [ ] Monitor sampling rates
- [ ] Adjust during incidents
