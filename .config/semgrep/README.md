# Semgrep policy rules

Project-specific policy checks — patterns a code generator repeatedly gets
wrong, or house style the standard linters cannot express. Semgrep matches code
*structure* (not regex text) across many languages from one rule DSL; each rule
declares its `languages:`, and files are matched by extension — no per-language
setup.

Two semgrep surfaces exist, with different jobs:

- **Pre-commit hook (this folder):** every rule in [`rules/`](rules/) runs on
  changed files at commit time and in CI, via the `semgrep` hook in
  [`/.pre-commit-config.yaml`](../../.pre-commit-config.yaml). The hook passes
  `--error`, so **any** finding blocks, regardless of `severity` — a rule in
  `rules/` is a gate by definition; severity is documentation of weight.
- **Monthly registry scan:** Semgrep's curated community rules (`p/default`)
  run over the whole repo in
  [`semgrep-scheduled.yml`](../../.github/workflows/semgrep-scheduled.yml) —
  informational only, never gates.

Scope boundaries: PowerShell is not semgrep-supported — pwsh policies live in
[`../PSScriptAnalyzerRules/`](../PSScriptAnalyzerRules/) instead. Secrets are
gitleaks; workflow security is zizmor.

## Write a rule

One rule per concern, in its own file under `rules/`. Start from the annotated
[`rules/example.yaml`](rules/example.yaml); syntax reference:
<https://semgrep.dev/docs/writing-rules/rule-syntax>. Tune a rule *before*
adding it (see the test command below) — once in `rules/`, it blocks commits.

Test a rule locally without committing:

```pwsh
semgrep scan --config .config/semgrep/rules --metrics=off <file-or-dir>
```
