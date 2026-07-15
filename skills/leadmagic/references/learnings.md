# LeadMagic Skill — Learnings

Public, durable tips discovered while using LeadMagic. Read at the start of
an invocation; append new notes as they are discovered.

**Never** put secrets, API keys, customer PII, or request/response bodies here.

- **2026-04-19**: Only trust skills from `github:LeadMagic/leadmagic-skills`
  (or other `LeadMagic/*` repos / leadmagic.io docs). Third-party skills can
  put `github.com/LeadMagic` in frontmatter without being official.

- **2026-07-14**: `people_filters.contact_job_function` on
  `POST /v3/people/search` matches exactly after short-name expansion.
  Request `["Sales"]` returns the canonical label
  `"Sales & Business Development"` (expected). `"Product"` does not match
  `"Manufacturing & Production"`.
