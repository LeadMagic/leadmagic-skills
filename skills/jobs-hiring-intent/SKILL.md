---
name: jobs-hiring-intent
description: "LeadMagic hiring research from public job search. Use when ranking accounts by open roles, researching hiring evidence, or building a hiring-based outreach brief."
license: MIT
compatibility: "Requires network access to api.leadmagic.io or mcp.leadmagic.io."
metadata:
  author: LeadMagic
  version: "3.0.1"
  homepage: https://leadmagic.io?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  docs: https://leadmagic.io/docs?utm_source=github&utm_medium=skill&utm_campaign=leadmagic-skills
  github: https://github.com/LeadMagic/leadmagic-skills
  publisher: LeadMagic
  tags: [leadmagic, jobs, hiring-intent, signals, triggers, outbound]
---

# LeadMagic — Jobs and hiring research

Use the `job-search` skill for `POST /v3/jobs/search`, filter resolution, public catalogs, cursors, and exports. Use public job-posting evidence to derive account signals; do not invent dedicated signal endpoints.

## Workflow

1. Define target companies, roles, geography, and time period.
2. Check `GET /v1/credits` and search entitlement. Professional and Ultimate include credit-free canonical jobs search; other plans are metered. Exports and enrichment remain metered on all plans. State and confirm paid work before running it.
3. Resolve filters with `POST /v3/jobs/search/resolve` and public catalogs.
4. Search and paginate with identical filters. Preserve posting IDs, dates, company identity, and source URLs.
5. Summarize openings by role and company. Infer hiring velocity only when comparable dated snapshots exist; a single result set does not establish a trend.
6. Label interpretations as hypotheses. A job posting does not prove purchase intent, an installed tool, or a budget.
7. Return a ranked account table with supporting evidence and missing-data notes. Obtain authorization before any outbound send.

## Output

Company, observed roles, posting dates, evidence URLs, relevance to the user's offer, confidence, and recommended next research step. Deduplicate reposts and avoid claiming a role remains open without checking the source.

## Public references

[Job search and pagination](https://leadmagic.io/docs/mcp/agent-guide) · [Public API schema](https://leadmagic.io/docs/api-reference/openapi.yml)
