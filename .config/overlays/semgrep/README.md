# Semgrep overlay (opt-in activation)

Semgrep is **not wired into pre-commit by default**. The rule files are real
and tracked at [`.config/semgrep/`](../../semgrep/README.md) — this overlay is
only the *activation* (the pre-commit hook fragment). Nothing runs until you
paste it in.

## Why activation is opt-in, not core

It was briefly wired in as an active hook + scheduled CI workflow and then
reverted. Two practical frictions drove that:

- An earlier Windows test of Semgrep's managed pre-commit repository checkout
  failed on case-colliding paths. This overlay therefore retains a
  `repo: local` PyPI installation. Semgrep added native Windows support in
  2025 and now recommends `pipx` on Windows, so this historical managed-hook
  failure should be revalidated before treating it as a current platform
  limitation ([Semgrep installation guidance](https://semgrep.dev/docs/update),
  [native Windows announcement](https://semgrep.dev/blog/2025/semgrep-community-edition-fall-release-2025)).
- This template is PowerShell-heavy, while Semgrep's current supported-language
  table does not list PowerShell or SQL. The shipped local rules cover only
  languages that were actually verified here; PSScriptAnalyzer remains the
  PowerShell policy engine
  ([Semgrep supported languages](https://semgrep.dev/docs/supported-languages)).

None of that makes semgrep *bad* — the shipped rules are verified and work —
but it does not clear the bar for base-template tooling every clone inherits by
default. Tracking issue for a replacement evaluation:
<https://github.com/DenWin/Template/issues/3>.

## Activate

1. **Install semgrep** — `pip install semgrep` (or `pipx install semgrep`).
2. **Wire the hook** — paste the block from
   [`precommit-hook.yaml`](precommit-hook.yaml) into the `repos:` list of
   [`/.pre-commit-config.yaml`](../../../.pre-commit-config.yaml). It installs
   from PyPI as a `repo: local` hook, preserving the configuration that was
   verified on this repository.
3. **Verify** — `semgrep scan --config .config/semgrep/rules --metrics=off .`
   should run clean, or report only intended findings.

## Why an overlay, not a placeholder

A half-configured tool that errors on every run trains people to ignore it.
Inert-but-complete means it never breaks a repo that ignores it, yet activation
is a paste-and-pin. Same rationale as the [Vale overlay](../vale/README.md).
