---
description: Monitor a competitor's ad creatives and mine messaging angles
argument-hint: [competitor domain(s)]
---

Research ads for: $ARGUMENTS

Follow `outbound-recipes` recipe 9 and the `ads-intelligence` skill (1/search + 2/detail):
1. Per domain: `google-ads-search`, `meta-ads-search`, `b2b-ads-search` with `limit` set (default 10).
2. If a previous run's output exists, diff — flag new/retired creatives; pull `b2b-ads-details` (2) only for new ones worth dissecting.
3. Report: channels active, core promises/offers, targeting hints, and 2–3 counter-positioning angles for cold outreach. An empty result = not advertising on that network (a finding, not an error — don't retry).
