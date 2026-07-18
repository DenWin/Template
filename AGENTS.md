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

| Mechanism           | Where                                                                                    | Doc                                                                                                              |
| ------------------- | ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Orchestration       | `.pre-commit-config.yaml` (root)                                                         | this file + inline comments                                                                                      |
| Configs             | `.config/`                                                                               | [`.config/README.md`](.config/README.md)                                                                         |
| Linting & testing   | `.config/scripts/`                                                                       | [`.config/scripts/README.md`](.config/scripts/README.md)                                                         |
| CI & automation     | `.github/`                                                                               | [`.github/README.md`](.github/README.md)                                                                         |
| Editor integration  | `.vscode/`                                                                               | [`.vscode/README.md`](.vscode/README.md)                                                                         |
| Policy rules        | `.config/PSScriptAnalyzerRules/`                                                         | [`.config/scripts/README.md`](.config/scripts/README.md)                                                         |
| Opt-in tooling      | `.config/overlays/`                                                                      | [`.config/overlays/README.md`](.config/overlays/README.md)                                                       |
| Documentation graph | Markdown/AsciiDoc + README indexes                                                       | [`docs/README.adoc`](docs/README.adoc)                                                                           |
| AI delegation       | `AGENTS.md`, `.claude/`, `.codex/`, `.github/copilot-instructions.md`, `.github/agents/` | [`CLAUDE.md`](CLAUDE.md) + [`.codex/config.toml`](.codex/config.toml) + [`.github/README.md`](.github/README.md) |
<!-- setup-teardown:template-only:start -->
| One-time repo setup | `setup/` (delete after use)      | [`setup/README.md`](setup/README.md)                                  |
| Optional AI skills  | `setup/optional-skills/`         | [`setup/optional-skills/README.adoc`](setup/optional-skills/README.adoc) |
<!-- setup-teardown:template-only:end -->

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

## Development workflow: TDD

Behavioral changes to the repo's scripts are developed test-first with the
`develop-with-tdd` skill. If that skill — or an equivalent TDD skill — is
already installed in your agent, use it; there is no need for a second copy.
<!-- setup-teardown:template-only:start -->
If none exists, use the bundled one at
[`setup/optional-skills/skills/develop-with-tdd/`](setup/optional-skills/skills/develop-with-tdd/SKILL.md):
install it into your agent's skill directory (Claude Code: `.claude/skills/`
in the repo, or `~/.claude/skills/` for all repos), or follow its `SKILL.md`
in place. The bundle is deleted with the rest of `setup/` at the end of
bootstrap — install it *before* running `Complete-Setup.ps1` if you want to
keep it.
<!-- setup-teardown:template-only:end -->

## Documentation relationships

This repo uses a deliberately reduced, non-conformant subset of the draft Open
Knowledge Format: ordinary Markdown links and AsciiDoc cross-references make
related documents discoverable, and README indexes provide progressive
disclosure without turning each consumer repo into a knowledge bundle. The
adopted and rejected conventions are recorded in
[`docs/knowledge-format.md`](docs/knowledge-format.md); do not copy the
upstream draft into this repo.

<!-- setup-teardown:template-only:start -->
**Keep the migration runbook connected.** When a change adds, removes, or
materially changes a permanent mechanism, agent entry point, delegation file,
documentation convention, or setup step, review
[`setup/MIGRATION.md`](setup/MIGRATION.md) in the same change. Update it when
the retrofit steps change; otherwise state in the PR why migration is
unaffected. This rule lives here because Codex reads `AGENTS.md` directly and
Claude imports it through `CLAUDE.md`.
<!-- setup-teardown:template-only:end -->

## Reuse: prefer an include over a copy; a symlink only when no include exists

When the same content must exist in more than one place, in order of
preference:

1. **Content-level include** — the format's own indirection: the `@AGENTS.md`
   import in `CLAUDE.md`, `extends` in markdownlint/VS Code settings, explicit
   config paths in pre-commit hook `args`. Degrades *loudly* (a missing file
   errors) and works on every machine — use it whenever the format offers one.
2. **Symlink** — when the format has no include mechanism. One source of
   truth, no copy drift. Git documents that `core.symlinks=false` checks
   symlinks out as small plain files containing the link text
   ([Git documentation](https://git-scm.com/docs/git-config#Documentation/git-config.txt-coresymlinks)).
   On Windows, creating symlinks without elevation also depends on Developer
   Mode ([Microsoft documentation](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development)).
   `Initialize-DevEnvironment.ps1` probes creation and warns when the machine
   cannot do it. Do **not** reach for an elevated shell as a workaround (that
   breaks pre-commit, see the bootstrap note).
3. **Copy** — only when the two files are meant to diverge.

<!-- setup-teardown:template-only:start -->
## Retrofit an existing repo

See [`setup/MIGRATION.md`](setup/MIGRATION.md) for the full step-by-step walkthrough of
bringing this architecture into a repo not scaffolded from this template — one
step per concept in the mechanism map above, in dependency order, including
the platform limitations you'll hit along the way (e.g. `merge_queue` on a
personal/user-owned repo).
<!-- setup-teardown:template-only:end -->

## Opening a pull request

`.github/pull_request_template.md` is the PR contract — `gh pr create` and the
web UI both pre-fill it from this repo. Fill every section; **Evidence is
mandatory** (how the change was validated: CI run, `pre-commit run --all-files`,
tests). CI enforces the machine half (a green required `Quality gate` check gates the
merge); this file enforces the narrative half. The template lives *in the repo*
(not only an org-level `.github` fallback) precisely so the CLI — and any agent
driving it — applies it automatically.
