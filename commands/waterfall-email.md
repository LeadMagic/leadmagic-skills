---
description: Cheapest-first contact waterfall — one reachable channel, minimum credits
argument-hint: [name + company, email, or profile URL]
---

Get a reachable channel for: $ARGUMENTS

Follow `outbound-recipes` recipe 3 strictly in cost order, stopping at the first success:
1. Have an email → validate (0.25). Valid → done.
2. Name + company → email-finder (1; miss is free).
3. Profile URL only → b2b-profile-email (5; miss is free).
4. Personal email acceptable for this use case → personal-email-finder (2).
5. Phone actually needed → mobile-finder (5; miss free) last.

Never run a step past the one that satisfied the needed channel; never run email→profile (10) just to get an email. Report the channel found, validation status, and credits spent.
