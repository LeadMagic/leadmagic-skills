---
name: ads-intelligence
description: "LeadMagic competitor ads research — Google Ads, Meta (Facebook/Instagram) Ads, and B2B ads library search plus single-ad details. Use when researching a competitor's ad creatives, messaging, or offers, monitoring ad changes over time, or mining ad copy for positioning and cold-email angles."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.0"
  homepage: https://leadmagic.io
  docs: https://leadmagic.io/docs
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, ads, google-ads, meta-ads, b2b-ads, competitive-intel]
---

# LeadMagic — Ads intelligence

## Endpoints

| Goal | Endpoint | Credits | Rate/min |
|---|---|---|---|
| Google ads by advertiser | `POST /v1/ads/google-ads-search` | 1 | 1,500 |
| Meta (FB/IG) ads | `POST /v1/ads/meta-ads-search` | 1 | 1,500 |
| B2B ads library | `POST /v1/ads/b2b-ads-search` | 1 | 1,500 |
| One B2B ad, full detail | `POST /v1/ads/b2b-ads-details` | 2 | 1,500 |

Search by `company_domain` (preferred) or company name. **Pass `limit`** to cap creatives returned — it caps spend too. Legacy aliases (`/google/searchads`, `/meta/searchads`, `/b2b/searchads`, `/b2b/ad-details`) still resolve.

```bash
curl -sS -X POST "https://api.leadmagic.io/v1/ads/meta-ads-search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"company_domain":"competitor.com","limit":10}'
```

## Rules

- Never invent or paraphrase-as-quote ad copy — report only creatives the API returned.
- Details (2) only for creatives worth dissecting; diff against last run first.
- An empty result usually means the advertiser isn't running ads on that network — that's a finding, not an error. Don't retry.

## Outbound patterns

- **Weekly competitor monitor** (recipe 9): 3 searches/competitor (1 each) → diff vs last week → details on new creatives (2) → messaging brief.
- **Angle mining**: competitor's ad promises become your cold-email counter-positioning ("they promise X; here's where X breaks").
- **Warm-account signal**: a target account running B2B ads = active budget + market pressure; stack with hiring signals (`jobs-hiring-intent`) for timing.
- MCP: `search_google_ads`, `search_meta_ads`, `search_b2b_ads`, `get_b2b_ad_details`.
