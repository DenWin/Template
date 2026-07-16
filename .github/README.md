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

### Protecting the default branch (once per repo)

The `merge_group` gate only fires if the branch has a **merge-queue ruleset**.
That ruleset — plus the PR requirement, the required `lint` check, and
force-push/deletion blocks — is applied by the one-time setup tooling:

```pwsh
pwsh -NoProfile -File setup/Protect-MainBranch.ps1
```

Run it **after** the first push and one CI run (so the `lint` check exists),
then delete the `setup/` folder. See [`setup/README.md`](../setup/README.md).

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
