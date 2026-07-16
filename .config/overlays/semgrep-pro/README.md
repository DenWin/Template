# Semgrep Pro overlay (documentation only — no license, not activated)

This folder is a **decision record**, not working config. It exists so the
tradeoff is written down once instead of rediscovered per repo.

The free-tier semgrep setup is the [`semgrep` overlay](../semgrep/README.md) —
also opt-in, also needing no account, license, or per-repo quota. Activating
that overlay is unaffected by anything below; this overlay only concerns
*Pro*-tier features layered on top of it.

## What Pro adds, and why it isn't on

Semgrep's **free/OSS CLI accepts a `languages: [powershell]` rule but silently
skips it** — 0 findings, no error, just a warning that it "requires Pro". Pro
also adds cross-file analysis, AI-assisted triage/remediation, and 60 AI
credits. Verified by testing against the running CLI (2026-07, semgrep 1.170.0).

The blocker is not cost tuning, it's a **hard account-wide cap**:

> Scan up to 10 repositories · Maximum 10 contributors

This template is cloned into new repos on purpose. Baking a Pro dependency into
the template would mean every repo created from it silently competes for one of
only 10 slots on the account — a scarce resource, not a per-repo toggle. That is
why this stays an inert, deliberately-activated overlay: the decision to spend a
slot belongs to a human, once, per repo that actually needs PowerShell
enforcement (or the other Pro features) badly enough to justify it.

## If you decide to activate it (on a specific repo)

1. Check the current slot count against the 10-repo cap before linking another
   one — <https://semgrep.dev/orgs/-/settings> (or your org's usage page).
2. Link the repo: <https://semgrep.dev/login>, then `semgrep login` locally / in
   CI.
3. Rules with `languages: [powershell]` (or other Pro-only targets) then run
   with `semgrep scan --pro` — the free-tier flag drops the Pro skip.
4. No PowerShell Pro rules exist in this repo yet — none are written or tested,
   since there is currently no account to verify them against. Write and verify
   them the same way the [bash rule](../../semgrep/rules/bash-no-blanket-strict-mode.yaml)
   was: a violating + a clean sample file, run through `semgrep scan`, before
   adding the rule to `.config/semgrep/rules/`.

## Re-evaluate if

- The account already holds a Pro subscription for other reasons (then the
  10-repo cap is a real, trackable constraint to budget against, not a blocker).
- PowerShell policy enforcement becomes valuable enough on a *specific* repo to
  spend one of the 10 slots on it deliberately.
