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

Third-party actions are **pinned by full commit SHA** (with a `# vN` comment for
readability) — a mutable tag can be re-pointed at malicious code, a SHA cannot.
Dependabot updates the pins and refreshes the comment. The `zizmor` pre-commit
hook enforces this and other workflow-security rules.

The `lint` job's first step is a **full-history secret scan** (`gitleaks-action`).
This is the one CI check that is *not* a local pre-commit hook, by design: the
pre-commit gitleaks hook scans only staged changes (a no-op in CI) and local
hooks are bypassable, so this server-side scan is the unbypassable backstop over
the whole history / PR range. It runs the same gitleaks engine, so no lint logic
is duplicated. `GITLEAKS_VERSION` in the workflow is kept in sync with the
managed hook revision so local and CI findings agree. Org-owned repos need a
free `GITLEAKS_LICENSE` secret; user-owned repos do not.

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

## `CODEOWNERS`

Auto-requests review from the listed owners when matching paths change; the
sensitive control surfaces (`.github/`, `.pre-commit-config.yaml`, `.config/`,
`AGENTS.md`, `setup/`) are called out explicitly. It only *requests* review
until "require code owner review" is turned on in the branch ruleset — left off
for solo repos, since you cannot approve your own PR.

## `pull_request_template.md`

Pre-fills every PR with Goal / Scope / Risk & rollback / **Evidence**. Evidence
is mandatory: a PR must carry proof it was validated (CI run, `pre-commit run
--all-files`, tests). Especially load-bearing for AI-authored changes.

## `dependabot.yml`

A scheduled, GitHub-hosted service (not a workflow, not push-driven). Its scope
is deliberately narrow — the only ecosystem in this template it can maintain is
**GitHub Actions versions** (`github-actions`, monthly). pre-commit hook pins are
updated by `pre-commit autoupdate`; PowerShell/npm deps are handled elsewhere.
A 7-day `cooldown` delays adopting a just-published version, leaving a window for
a compromised or yanked release to be caught upstream.
