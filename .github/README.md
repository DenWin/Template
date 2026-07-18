# CI & automation

Continuous integration and GitHub-hosted automation. See [`/AGENTS.md`](../AGENTS.md)
for the overall architecture.

## Copilot customization in this repository

Repository-scoped Copilot guidance is split by responsibility:

- Shared instructions for both Copilot CLI and GitHub Copilot live in
  [`.github/copilot-instructions.md`](copilot-instructions.md).
- Repository custom agents live in [`.github/agents/`](agents/).
- The `committer` custom agent is intentionally mechanical and
  manually selected (`disable-model-invocation: true`) so commit scope and
  wording remain lead-authored decisions.

Custom agents in this repository currently inherit the caller/default model
instead of pinning a `model` value. This avoids assuming model-selection parity
across Copilot surfaces. If a future agent pins `model`, document tested
fallback behavior here and in `copilot-instructions.md`; do not rely on silent
escalation to a more expensive model.

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
readability), following GitHub's recommendation to pin actions to a full-length
commit SHA as the only immutable release reference
([GitHub secure-use guidance](https://docs.github.com/en/enterprise-cloud@latest/actions/reference/security/secure-use)).
Dependabot updates those SHA pins and version comments
([supported ecosystems](https://docs.github.com/en/code-security/reference/supply-chain-security/supported-ecosystems-and-repositories)).
The `zizmor` pre-commit hook enforces this and other workflow-security rules.

The `lint` job's first step is a **full-history secret scan** (`gitleaks-action`).
This is the one CI check that is *not* a local pre-commit hook, by design: the
pre-commit gitleaks hook scans only staged changes (a no-op in CI) and local
hooks are bypassable, so this server-side scan is the unbypassable backstop over
the whole history / PR range. It runs the same gitleaks engine, so no lint logic
is duplicated. `GITLEAKS_VERSION` in the workflow is kept in sync with the
managed hook revision so rule definitions do not drift between local and CI
scans. Org-owned repos need a free `GITLEAKS_LICENSE` secret; user-owned repos
do not, per the
[Gitleaks Action licensing notes](https://github.com/gitleaks/gitleaks-action#license).

<!-- setup-teardown:template-only:start -->
### Protecting the default branch (once per repo)

The `merge_group` gate only fires if the branch has a **merge-queue ruleset**.
That ruleset — plus the PR requirement, the required `lint` check, and
force-push/deletion blocks — is applied by the one-time setup tooling:

```pwsh
pwsh -NoProfile -File setup/Protect-MainBranch.ps1
```

Run it **after** the first push and one CI run (so the `lint` check exists),
then delete the `setup/` folder. See [`setup/README.md`](../setup/README.md).
The trigger and ruleset relationship is documented by
[GitHub's merge-queue guide](https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue).
<!-- setup-teardown:template-only:end -->

### What CI installs

pre-commit auto-installs the *managed* hooks. CI additionally installs what the
`repo: local` pwsh hooks need — they fail fast if it's missing and never
self-install:

- PowerShell modules: `PSScriptAnalyzer`, `Pester`.
- Ruby gem: `asciidoctor` (backs `Test-AsciiDoc.ps1`).

## `CODEOWNERS`

Auto-requests review from the listed owners when matching paths change; the
sensitive permanent control surfaces (`.github/`,
`.pre-commit-config.yaml`, `.config/`, `AGENTS.md`, `CLAUDE.md`) are called out
explicitly. CODEOWNERS requests review by itself; enforcement requires a branch
rule that requires code-owner review
([GitHub documentation](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)).
That enforcement is left off for solo repos, since you cannot approve your own
PR.

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
a compromised or yanked release to be caught upstream. The option and its
behavior are defined in the
[Dependabot options reference](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference#cooldown-).

## Copilot validation checklist (CLI and GitHub Copilot)

When adding or changing `.github/copilot-instructions.md` or
`.github/agents/*.md`, validate both surfaces:

1. **Discovery**: the agent appears in Copilot CLI and in GitHub Copilot's
   repository custom-agent picker.
2. **Invocation**: selecting `committer` actually uses that profile.
3. **Tool restrictions**: the profile is limited to `execute`, `read`, and
   `search`.
4. **Contract behavior**: the agent rejects missing inputs, stops on `git status`
   mismatches, stages only named paths, commits verbatim, does not add trailers,
   does not bypass hooks, and never pushes.
