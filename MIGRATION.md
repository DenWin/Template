# MIGRATION.md — adopting this template in an existing repo

How to migrate this repo's concepts into a repo that was **not** created from
this template. This is the entry document: it names each concept, gives the
order to adopt them in, and links the reference doc that explains each one in
depth — read those as you reach each step.

For the architecture itself (what you are adopting and why), read
[`AGENTS.md`](AGENTS.md) first.

## The concepts and where they are explained

| Concept                              | Lives in                                                         | Reference doc                                                        |
| ------------------------------------ | ---------------------------------------------------------------- | -------------------------------------------------------------------- |
| Orchestration (the local workflow)   | `.pre-commit-config.yaml`                                        | [`AGENTS.md`](AGENTS.md) + inline comments                           |
| Tool configs                         | `.config/`                                                       | [`.config/README.md`](.config/README.md)                             |
| Shared lint/test scripts             | `.config/scripts/`                                               | [`.config/scripts/README.md`](.config/scripts/README.md)             |
| Policy rules (custom analyzer rules) | `.config/PSScriptAnalyzerRules/`                                 | [`.config/scripts/README.md`](.config/scripts/README.md)             |
| Opt-in overlays                      | `.config/overlays/`                                              | [`.config/overlays/vale/README.md`](.config/overlays/vale/README.md) |
| CI (GH Actions workflow)             | `.github/workflows/lint.yml`                                     | [`.github/README.md`](.github/README.md)                             |
| GitHub automation beyond CI          | `.github/` (Dependabot, CODEOWNERS, PR/issue templates)          | [`.github/README.md`](.github/README.md)                             |
| Editor integration                   | `.vscode/`                                                       | [`.vscode/README.md`](.vscode/README.md)                             |
| Root convention files                | `.editorconfig`, `.gitattributes`, `.gitignore`, `.claudeignore` | self-documenting (declarative)                                       |
| One-time server-side setup           | `setup/`                                                         | [`setup/README.md`](setup/README.md)                                 |
| Agent entry docs                     | `CLAUDE.md`, `AGENTS.md`, per-folder READMEs                     | themselves                                                           |

## Migration, in order

The order matters: the orchestrator comes first because every later step hangs
hooks off it, and server-side protection comes last because it requires a CI
run to have happened.

### 1. Adopt the orchestrator

Copy `.pre-commit-config.yaml` to the target repo's root and adapt the hook
list to its languages — drop hooks for languages the repo doesn't have, keep
the structure (managed hooks for off-the-shelf linters, `repo: local` hooks
for bespoke checks, stages as cadence). Remove any existing
`core.hooksPath`/`.githooks/` mechanism — pre-commit replaces it, and the two
conflict.

### 2. Relocate configs into `.config/`

Move tool configs out of root into `.config/`, referenced explicitly via hook
`args` (see [`.config/README.md`](.config/README.md) for which file feeds
which tool). Only files a tool *forces* to root stay there. Factor markdown
rules into `markdownlint.jsonc` so editor and CLI share one rule set.

### 3. Move custom checks into shared scripts

Any bespoke lint/test logic that lived in CI *and* a local hook becomes one
`.config/scripts/*.ps1` invoked as a `repo: local` hook — run identically in
both places; delete the duplicate. Follow the script contract in
[`.config/scripts/README.md`](.config/scripts/README.md): fail fast, never
self-install, no-op cleanly on nothing to check. Copy
`Initialize-DevEnvironment.ps1` (bootstrap) and `Invoke-TestLane.ps1` (test
lanes) as-is; tag the repo's Pester tests `Fast`/`Standard`/`Thorough` by
measured cost.

### 4. Collapse CI to one workflow

Replace split per-language workflows with one `lint.yml` that runs
`pre-commit run` — scoped to the diff on `pull_request`, full on `merge_group`
(see [`.github/README.md`](.github/README.md)). Path-filtering becomes
unnecessary: pre-commit scopes by file. Keep the full-history gitleaks scan as
the one CI-only step, pin third-party actions by commit SHA, and bring over
`dependabot.yml`, `CODEOWNERS`, and the PR/issue templates, adapting owners
and paths.

### 5. Wire the editor

Copy `.vscode/settings.json` and `extensions.json`
(see [`.vscode/README.md`](.vscode/README.md)) so the same rules surface live
while typing. Keep the `.gitignore` pattern that tracks only the shipped
files.

### 6. Copy the docs and root conventions

Copy `AGENTS.md`, `CLAUDE.md`, and the per-folder READMEs, trimming each to
the tools the target repo actually uses. Copy the root convention files
(`.editorconfig`, `.gitattributes`, `.gitignore`, `.claudeignore`) and merge
with what exists. Where the same file must exist twice, prefer a symlink over
a copy (rationale and the Windows caveat: [`AGENTS.md`](AGENTS.md)).

### 7. Purge phantoms

Verify every referenced tool actually exists and every hook actually runs —
e.g. there is no `asciidoctor-lint` gem; AsciiDoc is checked via
`asciidoctor --failure-level` plus Vale for prose. A hook that silently checks
nothing is worse than no hook.

### 8. Apply server-side protection, then delete `setup/`

After the first push and one green CI run (the `lint` check must exist),
run the one-time scripts from [`setup/README.md`](setup/README.md) with
admin + `gh`:

```pwsh
pwsh -NoProfile -File setup/Protect-MainBranch.ps1
pwsh -NoProfile -File setup/Enable-RepoSecurity.ps1
```

They create the merge-queue ruleset on the default branch and enable the
server-side security settings. Then delete the `setup/` folder — it has
served its purpose.

## Verify the migration

- `pre-commit run --all-files` passes locally.
- A test PR shows the `lint` check running scoped to the diff, and merging
  routes through the merge queue (full run at the gate).
- The editor surfaces the same findings the commit hook enforces.

Anti-pattern this migration removes: local hook logic and CI workflows
re-implementing "the same" checks separately, which drift apart. One
orchestrator, one source.
