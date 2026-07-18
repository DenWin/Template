# Semgrep Pro overlay (documentation only — no license, not activated)

This folder is a **decision record**, not working config. It exists so the
tradeoff is written down once instead of rediscovered per repo.

The free-tier semgrep setup is the [`semgrep` overlay](../semgrep/README.md) —
also opt-in, also needing no account, license, or per-repo quota. Activating
that overlay is unaffected by anything below; this overlay only concerns
*Pro*-tier features layered on top of it.

## What the hosted free tier adds, and why it isn't on

Semgrep's current free hosted offering includes Pro rules, cross-file analysis,
and AI features, but its pricing page caps private repositories at 10 and its
usage policy caps private-project organizations at 10 monthly contributors.
Public projects have no contributor limit. These are service-plan constraints,
not limits on unauthenticated local Community Edition scans
([pricing](https://semgrep.dev/pricing/),
[usage and billing](https://semgrep.dev/docs/usage-limits/)).

This template is cloned into new repositories on purpose, so it does not spend
hosted private-repository capacity by default. The current supported-language
table also does not list PowerShell; do not adopt this overlay merely on the
assumption that a Pro login adds PowerShell analysis
([supported languages](https://semgrep.dev/docs/supported-languages)).

## If you decide to activate it (on a specific repo)

1. Check the current plan and private-repository/contributor usage before
   linking another repository — <https://semgrep.dev/orgs/-/settings> (or your
   organization's usage page).
2. Link the repo: <https://semgrep.dev/login>, then `semgrep login` locally / in
   CI.
3. Run the rules for a language currently documented as supported, using the
   product mode required by the chosen rules.
4. No PowerShell rules exist in this repo. Write and verify any future rule the
   same way the [bash rule](../../semgrep/rules/bash-no-blanket-strict-mode.yaml)
   was: a violating + a clean sample file, run through `semgrep scan`, before
   adding the rule to `.config/semgrep/rules/`.

## Re-evaluate if

- The account already has a suitable plan and available private-repository and
  contributor capacity.
- Semgrep officially adds the target language and its analysis is verified
  against representative positive and negative fixtures.
