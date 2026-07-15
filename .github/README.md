# CI & automation

Continuous integration and GitHub-hosted automation. See [`/AGENTS.md`](../AGENTS.md)
for the overall architecture.

## `workflows/lint.yml` — the CI half of "same checks, both places"

There is **no bespoke CI lint logic**. The workflow runs the exact same
`pre-commit` hooks a developer runs locally, at two cadences:

| Trigger        | Scope                                           | Purpose                           |
| -------------- | ----------------------------------------------- | --------------------------------- |
| `pull_request` | scoped to the PR diff (`--from-ref`/`--to-ref`) | fast feedback, fewer CI minutes   |
| `merge_group`  | full — every file + every test lane             | the gate *before* merging to main |
| `push: main`   | full                                            | post-merge safety net             |

File-scoped linters run only over changed files on a PR; the test hooks are
`always_run`, so the fast lane runs in full regardless.

### Enabling the merge gate (once per repo)

For the full set to gate a merge (not just run after), the default branch needs
a **merge queue** ruleset that requires the `lint` check. The `merge_group` event
then validates the queued commit **before** it reaches `main`; without it,
`push: main` still runs the full set, but only *after* the merge has landed.

Do this **after** the first push and one CI run (so the `lint` check exists):

```pwsh
pwsh -NoProfile -File .config/scripts/Enable-MergeQueue.ps1
```

The script creates the ruleset via `gh`. Equivalent manual path: *Settings →
Rules → Rulesets → New → require merge queue + require the `lint` status check*.

### What CI installs

pre-commit auto-installs the *managed* hooks. CI additionally installs what the
`repo: local` pwsh hooks need — they fail fast if it's missing and never
self-install:

- PowerShell modules: `PSScriptAnalyzer`, `Pester`.
- Ruby gem: `asciidoctor` (backs `Test-AsciiDoc.ps1`).

## `dependabot.yml`

A scheduled, GitHub-hosted service (not a workflow, not push-driven). Its scope
is deliberately narrow — the only ecosystem in this template it can maintain is
**GitHub Actions versions** (`github-actions`, monthly). pre-commit hook pins are
updated by `pre-commit autoupdate`; PowerShell/npm deps are handled elsewhere.
