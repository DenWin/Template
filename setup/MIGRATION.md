# MIGRATION.md — bringing this tooling into a different repo

**Executable runbook for migrating this template's tooling into a repo that
wasn't scaffolded from it** — including repos that went the wrong direction
with hand-wired custom workflows. Written so an AI agent (or a human) can work
through it step by step inside the *target* repo; every step ends with a
verifiable "done when".

For the architecture itself, see [`/AGENTS.md`](../AGENTS.md) — read that
first. [`CHANGELOG.md`](CHANGELOG.md) has the version history.

This file lives in `setup/` alongside the one-time setup tooling — it's only
needed during the migration, so it goes away with the rest of the folder when
`Complete-Setup.ps1` runs (step 13).

## The concepts you're migrating

| #  | Concept             | Lives in                                                                                 | Doc                                                                                               |
| -- | ------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| 1  | Orchestration       | `.pre-commit-config.yaml` (root)                                                         | [`/AGENTS.md`](../AGENTS.md) + inline comments                                                    |
| 2  | Configs             | `.config/`                                                                               | [`/.config/README.md`](../.config/README.md)                                                      |
| 3  | Linting & testing   | `.config/scripts/`                                                                       | [`/.config/scripts/README.md`](../.config/scripts/README.md)                                      |
| 4  | Policy rules        | `.config/PSScriptAnalyzerRules/`                                                         | [`/.config/scripts/README.md`](../.config/scripts/README.md)                                      |
| 5  | Opt-in tooling      | `.config/overlays/`                                                                      | [`/.config/overlays/README.md`](../.config/overlays/README.md)                                    |
| 6  | CI & automation     | `.github/`                                                                               | [`/.github/README.md`](../.github/README.md)                                                      |
| 7  | Editor integration  | `.vscode/`                                                                               | [`/.vscode/README.md`](../.vscode/README.md)                                                      |
| 8  | Documentation graph | Markdown/AsciiDoc + README indexes                                                       | [`/docs/knowledge-format.md`](../docs/knowledge-format.md)                                        |
| 9  | AI delegation       | `AGENTS.md`, `.claude/`, `.codex/`, `.github/copilot-instructions.md`, `.github/agents/` | [`/CLAUDE.md`](../CLAUDE.md) + tool-specific config + [`.github/README.md`](../.github/README.md) |
| 10 | Optional AI skills  | `setup/optional-skills/`                                                                 | [`optional-skills/README.adoc`](optional-skills/README.adoc)                                      |
| 11 | One-time repo setup | `setup/` (delete after use)                                                              | [`README.md`](README.md)                                                                          |

Root convention files provide defaults: `.editorconfig`, `.gitattributes`
(`eol=lf`), `.gitignore`, and `.claudeignore`. Copy them, then adapt ignore and
unignore rules to the target repository's languages and tracked editor files.

## Migration steps

Work through these in order — later steps depend on earlier ones (CI can't be
collapsed to one workflow until the scripts it calls exist; the merge gate
can't be enabled until CI has run once). All commands run from the target
repo's root.

1. **Export the template as the local reference copy.**

   ```bash
   gh repo clone DenWin/Template .temp/template -- --depth 1
   ```

   Check `.temp/` is gitignored in the target *before* the clone lands; add
   `/.temp/` to `.gitignore` if it isn't. Every "copy X" below means: copy
   from `.temp/template/X`, then adapt.
   *Done when:* `.temp/template/AGENTS.md` exists and `git status` shows no
   `.temp/` entries.

2. **Adopt the orchestrator.** Copy `.pre-commit-config.yaml` and adapt the
   hook list to the target repo's languages. Remove any `core.hooksPath` /
   `.githooks/` setup — pre-commit replaces it; the two conflict if both are
   set. Inventory the target's existing local hooks and CI workflows first:
   every check they perform must end up either in a managed hook, a
   `repo: local` script (step 4), or be consciously dropped — list the
   mapping in the migration PR description.
   *Done when:* `pre-commit run --all-files` executes (failures are fine —
   they're the backlog for the next steps). This is not a repository-history
   secret audit: the managed Gitleaks hook intentionally scans staged changes.

3. **Relocate configs** into `.config/` (concept 2), referenced explicitly via
   hook `args` — keep only root-*forced* files at root. Factor markdown rules
   into `markdownlint.jsonc` so the CLI and editor share one source.
   *Done when:* no linter config sits at root except forced ones, and
   `pre-commit run --all-files` still finds every config.

4. **Move custom checks into shared scripts** (concept 3). Any bespoke
   lint/test logic duplicated between CI and a local hook becomes one
   `.config/scripts/*.ps1` invoked as a `repo: local` hook, run identically in
   both places. Delete the duplicate. Carry over
   `.config/PSScriptAnalyzerRules/` (concept 4) if the target repo has
   PowerShell to lint. Tests for setup-time scripts live in `setup/tests/`;
   tests for permanent scripts sit next to the script — the Pester lane runner
   discovers `*.Tests.ps1` recursively either way.
   *Done when:* no check exists twice, and the test lanes
   (`Invoke-TestLane.ps1 -Lane Fast`) run green or report "no tests".

5. **Bring opt-in tooling across as inert overlays** (concept 5) — start from
   `.config/overlays/README.md`, then select Vale, Semgrep, or another relevant
   overlay. Follow the selected overlay's structure; some carry a
   `precommit-hook.yaml` fragment, while documentation-only decision records do
   not. Do not activate a fragment unless the target needs it now.
   *Done when:* overlays exist but `pre-commit run --all-files` doesn't run
   them.

6. **Collapse CI to one workflow** (concept 6) that runs `pre-commit run` —
   scoped to the diff on `pull_request`, full on `merge_group` and
   `push: main`. Replace N split per-language workflows; path filtering is no
   longer needed since pre-commit scopes by file. Keep the separate
   full-history/PR-range Gitleaks Action as the deliberate server-side
   backstop, and keep its `GITLEAKS_VERSION` aligned with the managed hook
   revision so their rule definitions do not drift. Carry over `CODEOWNERS`,
   issue templates, and `pull_request_template.md` for the same
   Evidence-mandatory PR contract.
   *Done when:* exactly one quality-gate workflow remains and a test PR shows the
   `Quality gate` check green.

7. **Wire the editor** (concept 7): copy `.vscode/settings.json` (`extends`
   the same `.config/markdownlint.jsonc`) and `.vscode/extensions.json`, and
   check the target's `.gitignore` un-ignores exactly those two files (plus
   `.vscode/README.md` if you copy that doc too) — see the ignore rule in this
   repo's `.gitignore` for the pattern.
   *Done when:* the three files are tracked (`git ls-files .vscode/` lists
   them) and nothing else in `.vscode/` is.

8. **Adopt the documentation graph** (concept 8). Copy
   `docs/knowledge-format.md` and adapt its deliberately reduced OKF-inspired
   conventions to the target. Treat Markdown and AsciiDoc as first-class:
   use each format's native relative links/cross-references, use README files as
   directory indexes where progressive disclosure helps, and cite external
   claims. Do not add mandatory frontmatter, reserved
   `index.md`/`log.md` semantics, or an OKF conformance claim unless the target
   is intentionally becoming an exchangeable knowledge bundle.
   *Done when:* permanent docs are reachable from `AGENTS.md` or a linked
   README and related documents link to each other explicitly.

9. **Adopt the AI entry points and delegation policy** (concept 9). Copy
   `AGENTS.md` as shared repository guidance, then copy only the product
   layers the target uses: `CLAUDE.md` and `.claude/agents/` for Claude Code;
   `.codex/config.toml` and `.codex/agents/` for Codex; and
   `.github/copilot-instructions.md` plus `.github/agents/` for Copilot CLI and
   GitHub Copilot. Adapt model names and supported capabilities rather than
   copying them blindly. Keep shared principles in `AGENTS.md`, but keep
   product-only model names and mechanics in product entry points.
   Claude imports the shared file, while Codex reads it directly and adds its
   own `developer_instructions` from `.codex/config.toml` in trusted projects.
   Review [`docs/token-saving.adoc`](../docs/token-saving.adoc) before making
   mechanical commit delegation a default; it usually preserves parent context
   rather than reducing total tokens. For Copilot custom agents, treat explicit
   `model` pinning as opt-in: validate support in both Copilot CLI and GitHub
   Copilot, and document fail-fast fallback behavior before pinning.
   *Done when:* every retained product entry point loads the shared guidance,
   every referenced custom agent exists, Copilot custom agents are discoverable
   in both Copilot CLI and GitHub Copilot, and no unused product layer remains.

10. **Copy optional AI skills only when needed** (concept 10). Read
    [`optional-skills/README.adoc`](optional-skills/README.adoc), install a
    bundled skill only when the target agent has no equivalent, and copy the
    complete skill directory with its runtime references. Copy the human TDD
    knowledge base only when the target should retain that learning material.
    *Done when:* each retained skill loads in the target agent and no duplicate
    equivalent skill was installed.

11. **Copy the remaining docs.** Bring over the per-folder READMEs, trimmed to
    the target repo's actual tools, and update them to reflect what you
    migrated. Purge phantoms: verify every referenced tool exists in the
    target repo (e.g. there is no `asciidoctor-lint` gem — use
    `asciidoctor --failure-level` for syntax and Vale for prose). A doc that
    lists a nonexistent tool is worse than no doc.
    *Done when:* every tool named in a doc can be invoked in the target repo.

12. **Copy and run the one-time setup tooling** (concept 11) after the first
    push and one CI run (so the `Quality gate` check the ruleset requires actually
    exists): copy the whole `setup/` folder (including this file and
    `optional-skills/` only if step 10 needs it), then follow
    [`README.md`](README.md) — protection, security settings, AI-maintainer
    identity, in that order.
    **If the target repo is owned by a personal/user account** (not an
    organization), expect `merge_queue` to be rejected by GitHub — a
    [documented availability constraint](https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue),
    not a bug. Use a GitHub App rather than a separate collaborator account's
    fine-grained PAT. `Protect-MainBranch.ps1` posts each rule as its own
    ruleset for exactly this reason: the other protections still land.
    *Done when:* the rulesets appear in repo settings and
    `Test-AIMaintainerIdentity.ps1` passes from the agent's shell.

13. **Finish.** Delete the reference copy (`.temp/template/`), then run
    `pwsh -NoProfile -File setup/Complete-Setup.ps1` — it removes `setup/`
    and opens the removal PR (and refuses to run if the repo is itself a
    template repo).
    *Done when:* the removal PR is open and CI on it is green.

## Anti-pattern this replaces

Local hook logic and CI workflows re-implementing "the same" checks
separately, which drift apart over time. One orchestrator, one source, copied
concept by concept rather than file by file.
