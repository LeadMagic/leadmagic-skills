---
description: Size and segment a market for free before revealing rows
argument-hint: [market description, e.g. "US fintechs 11-500 employees"]
---

Map the TAM for: $ARGUMENTS

Follow `outbound-recipes` recipe 11:
1. Translate the market into `company_filters` permutations (industry × size band × geo).
2. Run the FREE stats/count surfaces per segment — no reveals yet. Build the segment matrix with match counts.
3. Report the map, recommend which segments to actually work, and the reveal cost per segment (1/row; free on Professional/Ultimate). Only reveal (`/v3/companies/search`) segments the user picks.
