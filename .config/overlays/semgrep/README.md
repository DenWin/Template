# Semgrep overlay (opt-in activation)

Semgrep is **not wired into pre-commit by default**. The rule files are real
and tracked at [`.config/semgrep/`](../../semgrep/README.md) — this overlay is
only the *activation* (the pre-commit hook fragment). Nothing runs until you
paste it in.

## Why activation is opt-in, not core

It was briefly wired in as an active hook + scheduled CI workflow and then
reverted. Two real frictions drove that:

- **The managed pre-commit hook does not work on Windows** — pre-commit clones
  semgrep's own git repo, which contains case-colliding paths that fail
  checkout on NTFS. The `repo: local` PyPI-wheel workaround below fixes it but
  adds install weight and a `require_serial: true` workaround for a
  `~/.semgrep/settings.yml` race between parallel instances.
- **Its language coverage has real gaps for this template's stack**: SQL has
  no support at any tier; **PowerShell parses but Pro-gates rule execution**
  (free CLI silently reports 0 findings — see
  [`../semgrep-pro/README.md`](../semgrep-pro/README.md)), and Pro is capped at
  10 repos account-wide — unsuitable for a template cloned into many repos.

None of that makes semgrep *bad* — the shipped rules are verified and work —
but it does not clear the bar for base-template tooling every clone inherits by
default. Tracking issue for a replacement evaluation:
<https://github.com/DenWin/Template/issues/3>.

## Activate

1. **Install semgrep** — `pip install semgrep` (or `pipx install semgrep`).
2. **Wire the hook** — paste the block from
   [`precommit-hook.yaml`](precommit-hook.yaml) into the `repos:` list of
   [`/.pre-commit-config.yaml`](../../../.pre-commit-config.yaml). It installs
   from PyPI as a `repo: local` hook (not the managed `repo:` clone, which
   fails on Windows — see above).
3. **Verify** — `semgrep scan --config .config/semgrep/rules --metrics=off .`
   should run clean, or report only intended findings.

## Why an overlay, not a placeholder

A half-configured tool that errors on every run trains people to ignore it.
Inert-but-complete means it never breaks a repo that ignores it, yet activation
is a paste-and-pin. Same rationale as the [Vale overlay](../vale/README.md).
