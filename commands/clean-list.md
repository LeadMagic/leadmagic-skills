---
description: Validate an email list before sending (deliverability hygiene)
argument-hint: [path/to/list.csv]
---

Clean this send list: $ARGUMENTS

Follow `outbound-recipes` recipe 5: bulk `email_validation` (0.25/conclusive row; `unknown` is free) over the list. Preflight balance + projected cost first and confirm. The only public statuses are `valid`, `invalid`, and `unknown`: send only `valid`; route `invalid` and `unknown` through the email waterfall. Do not treat `unknown` as valid or send-ready. Write the three status segments and report counts per bucket.
