# Semgrep policy rules

Project-specific policy checks — patterns a code generator repeatedly gets
wrong, or house style the standard linters cannot express. These rule files are
tracked, real, and verified — but **nothing runs them by default**. Wiring
semgrep into pre-commit is opt-in: see
[`.config/overlays/semgrep/README.md`](../overlays/semgrep/README.md) to
activate.

Scope boundaries: Semgrep's current
[supported-language table](https://semgrep.dev/docs/supported-languages) does
not list PowerShell or SQL. PowerShell policies therefore live in
[`../PSScriptAnalyzerRules/`](../PSScriptAnalyzerRules/) instead — that
mechanism is active in the base template today. Do not infer support merely
because a parser accepts a language name; verify a positive and negative
fixture against the current engine. Secrets are gitleaks; workflow security is
zizmor. The hosted-service trade-offs are recorded in
[`../overlays/semgrep-pro/README.md`](../overlays/semgrep-pro/README.md).

## Rules shipped here

- [`rules/python-no-silently-swallowed-exception.yaml`](rules/python-no-silently-swallowed-exception.yaml) —
  Python, empty-except swallowing.
- [`rules/bash-no-blanket-strict-mode.yaml`](rules/bash-no-blanket-strict-mode.yaml) —
  bash, flags blanket `set -e`/`set -euo pipefail` (shellcheck, the base-template
  bash linter, has no opinion on this — it's a style choice, not a mechanic).

Both are verified: run against a violating and a clean sample file through the
real hook before being added. Test a rule the same way:

```pwsh
semgrep scan --config .config/semgrep/rules --metrics=off <file-or-dir>
```

Syntax reference: <https://semgrep.dev/docs/writing-rules/rule-syntax>.
