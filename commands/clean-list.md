---
description: Validate an email list before sending (deliverability hygiene)
argument-hint: [path/to/list.csv]
---

Clean this send list: $ARGUMENTS

Follow `outbound-recipes` recipe 5: bulk `email_validation` (0.25/conclusive row; unknown free) over the list. Preflight balance + projected cost first and confirm. Then segment the output: `valid` (send), `catch_all` (send only if the user accepts the risk), `unknown` / `invalid` (route back through the email waterfall). Write the segmented files and report counts per bucket.
