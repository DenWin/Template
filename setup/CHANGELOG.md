# Changelog

Notable changes to this template, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/). The current version
is tracked in [`version`](version) and bumped in the commit that ships it —
there are no git tags or releases, so version sections carry no release date
until one is cut. Rationale lives with each mechanism's doc
([`/AGENTS.md`](../AGENTS.md), per-folder READMEs, script headers) — this file
records only what changed.

## [0.4.0]

### Added

- `New-AIMaintainerToken.ps1` for cryptographically signed,
  repository-scoped GitHub App installation tokens.
- Teardown markers and permanent-document cleanup in `Complete-Setup.ps1`.
- Indexes for optional skills, overlays, and permanent docs.
- A sourced token-saving knowledge base and three retained TDD assessment
  artifacts.

### Changed

- The complete human TDD knowledge base is now AsciiDoc; runtime skill files
  remain Markdown.
- Markdown and AsciiDoc follow the same reduced OKF-inspired documentation
  convention.
- Mechanical committer delegation is opt-in when isolation or parallel work
  justifies its additional tokens.
- AI-maintainer guidance now recommends GitHub Apps for personal repositories,
  documents fine-grained PAT collaborator limits, and distinguishes local
  commit signing from API-created bot verification.
- The migration runbook covers the updated documentation, overlay, optional
  skill, and AI-maintainer mechanisms.

### Fixed

- `Complete-Setup.ps1` now verifies the AI-maintainer identity and removes
  dangling `setup/` references from permanent documents.
- Semgrep and GitHub behavior claims now link to current primary sources and no
  longer present historical Windows or plan constraints as universal.

## [0.3.0]

### Added

- `setup/version` and this versioned changelog.
- `setup/Test-AIMaintainerIdentity.ps1` — fails unless the agent shell's
  credential is an App installation token or fine-grained PAT without admin.
- `setup/New-AIMaintainerApp.ps1` — least-privilege GitHub App creation via
  the app-manifest flow (one browser confirmation; no pure-API path exists).
- `setup/Complete-Setup.ps1` — removes `setup/` and opens it as the first PR;
  refuses on template repos (`isTemplate`) and dirty worktrees.
- `setup/optional-skills/` — bundled skills (`develop-with-tdd` + its TDD
  knowledge base, and `changelog-entry` for adding entries to this file);
  install before `Complete-Setup.ps1` only if no equivalent exists.
- Symlink capability probe + warning in `Initialize-DevEnvironment.ps1`.

### Changed

- Setup-time tests moved to `setup/tests/`.
- `MIGRATION.md` rewritten as an executable runbook (exports the template to
  `.temp/template/`; each step has a "done when").
- `AGENTS.md` reuse rule: content-level include > symlink > copy.
- asciidoctor capability check probes an actual run (a `.bat` shim can be on
  PATH without its Ruby backend).
- `MD024` relaxed to `siblings_only` in `.config/markdownlint.jsonc`.

### Fixed

- `Test-PowerShellScript.ps1` crashed under StrictMode when PSScriptAnalyzer
  returned exactly one finding.
- "Clean script" test fixture predated the `Measure-RequireStrictMode` rule.

## [0.2.0]

### Added

- `merge_queue` rule in `Protect-MainBranch.ps1`.

### Removed

- `merge_queue` from this repo's live rulesets — GitHub only supports it on
  org-owned repos; `DenWin/Template` is user-owned.

### Changed

- `Protect-MainBranch.ps1` posts one ruleset per rule so a single rejected
  rule (e.g. `merge_queue`) can't block the others.

## [0.1.0]

### Added

- Pre-commit orchestration: managed hooks + `repo: local` pwsh scripts under
  `.config/scripts/`, shared by local hooks and CI.
- Single CI workflow running the same pre-commit hooks (diff-scoped on PRs,
  full at the merge gate).
- `.vscode/` editor integration extending the same lint configs.
- Custom PSScriptAnalyzer rule `Measure-RequireStrictMode`.
- semgrep rules as an opt-in overlay (`.config/overlays/`).
- `CODEOWNERS`, issue templates, PR template with mandatory Evidence section.
- `zizmor` hook and full-history `gitleaks-action` in CI.
- `setup/`: `Protect-MainBranch.ps1`, `Enable-RepoSecurity.ps1`,
  `AI-Maintainer-Identity.adoc` (replacing `Enable-MergeQueue.ps1`).

### Changed

- `New-IsolatedScript` renamed `Get-IsolatedScript` (query verb convention).
- Dependabot bumps for SHA-pinned third-party Actions.
- semgrep wiring reverted to overlay-only (rules kept).
