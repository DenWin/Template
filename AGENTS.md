# AGENTS.md — tooling architecture & retrofit guide

**Entry point for AI agents.** This file describes the repo's linting/testing
architecture and how to reproduce it in another repo. Human contributors: the
per-mechanism docs linked below are the reference; [`README.md`](README.md) is
the (replaceable) project stub.

## The idea in one paragraph

**One orchestrator (`pre-commit`) runs the same checks locally and in CI — no
duplication.** Standard linters run as managed pre-commit hooks. Checks with no
native backend (PowerShell, AsciiDoc, tests) are `repo: local` hooks calling
shared `.config/scripts/*.ps1` that CI runs verbatim. Tool configs live under
`.config/` to keep root lean. CI runs *the same hooks* — scoped to the diff on
PRs, full at the merge gate.

## Mechanism map

| Mechanism           | Where                            | Doc                                                                  |
| ------------------- | -------------------------------- | -------------------------------------------------------------------- |
| Orchestration       | `.pre-commit-config.yaml` (root) | this file + inline comments                                          |
| Configs             | `.config/`                       | [`.config/README.md`](.config/README.md)                             |
| Linting & testing   | `.config/scripts/`               | [`.config/scripts/README.md`](.config/scripts/README.md)             |
| CI & automation     | `.github/`                       | [`.github/README.md`](.github/README.md)                             |
| Editor integration  | `.vscode/`                       | [`.vscode/README.md`](.vscode/README.md)                             |
| Policy rules        | `.config/PSScriptAnalyzerRules/` | [`.config/scripts/README.md`](.config/scripts/README.md)             |
| Opt-in tooling      | `.config/overlays/`              | [`.config/overlays/vale/README.md`](.config/overlays/vale/README.md) |
| One-time repo setup | `setup/` (delete after use)      | [`setup/README.md`](setup/README.md)                                 |

Root convention files are declarative and self-documenting: `.editorconfig`
(style), `.gitattributes` (eol=lf), `.gitignore`, `.claudeignore`.

## Orchestration (the root mechanism)

`.pre-commit-config.yaml` is the single source of hook definitions (forced to
root). Key principles encoded there:

- **Managed vs local hooks.** Off-the-shelf linters (yamllint, markdownlint,
  shellcheck, shfmt, actionlint, zizmor, gitleaks) are managed hooks.
  PowerShell/AsciiDoc/tests are `repo: local` hooks → `.config/scripts/*.ps1`.
- **Stages = cadence.** `pre-commit` (commit), `pre-push` (push), `manual`
  (CI/merge). Test lanes map to these; standard/thorough ship commented-in-place.
- **Local hooks fail fast**, never self-install. Bootstrap is explicit
  (`.config/scripts/Initialize-DevEnvironment.ps1`).

## Reuse: prefer a symlink over a copy

When the same file must exist in more than one place, **symlink it** instead of
copying — one source of truth, no drift (ai-lab copied such files and they
drifted). Git tracks symlinks natively.

- **Windows:** enable **Developer Mode** (Settings → For developers) so symlinks
  materialize *without admin rights* — do **not** reach for an elevated shell
  (that breaks pre-commit, see the bootstrap note). Without it, git checks
  symlinks out as plain text files holding the target path. Keep
  `git config core.symlinks true`.
- Reserve copies for cases where the two files are meant to diverge.

## Retrofit an existing repo

The step-by-step guide for bringing a repo **not** created from this template
up to this architecture lives in [`MIGRATION.md`](MIGRATION.md) — the entry
document that lists every concept, orders the migration (orchestrator first,
server-side protection last), and links each concept's reference doc.

Anti-pattern this replaces: local hook logic and CI workflows re-implementing
"the same" checks separately, which drift apart. One orchestrator, one source.

## Opening a pull request

`.github/pull_request_template.md` is the PR contract — `gh pr create` and the
web UI both pre-fill it from this repo. Fill every section; **Evidence is
mandatory** (how the change was validated: CI run, `pre-commit run --all-files`,
tests). CI enforces the machine half (a green required `lint` check gates the
merge); this file enforces the narrative half. The template lives *in the repo*
(not only an org-level `.github` fallback) precisely so the CLI — and any agent
driving it — applies it automatically.
