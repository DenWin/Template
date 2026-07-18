# One-time repo setup

Tooling to run **once** on a new repo created from this template, in this
order — the last step deletes this whole folder via its own PR. Tests for
these scripts live in [`tests/`](tests/): this folder reads as an ordered
runbook, so tests are kept out of its root rather than co-located beside each
script (the repo-wide default — see [`.config/scripts/README.md`](../.config/scripts/README.md)).
They still leave with the folder on teardown. [`CHANGELOG.md`](CHANGELOG.md)
has the version history; the current version is in [`version`](version).

Bringing this tooling into a repo that *wasn't* created from this template
instead? Start with [`MIGRATION.md`](MIGRATION.md) — an executable runbook
that walks through every concept, not just this folder's scripts.

All steps at a glance (details in the sections below):

```pwsh
# 1. Protect the default branch
pwsh -NoProfile -File setup/Protect-MainBranch.ps1

# 2. Enable server-side security settings
pwsh -NoProfile -File setup/Enable-RepoSecurity.ps1

# 3. Set up the AI-maintainer identity, then verify it FROM THE AGENT'S SHELL
pwsh -NoProfile -File setup/New-AIMaintainerApp.ps1
# After installation, mint a repository-scoped token as shown by the script.
pwsh -NoProfile -File setup/Test-AIMaintainerIdentity.ps1

# Optional: install the bundled AI skills before they are deleted with setup/
Copy-Item -Recurse setup/optional-skills/skills/develop-with-tdd ~/.claude/skills/

# 4. Remove this folder and open it as the repo's first PR
pwsh -NoProfile -File setup/Complete-Setup.ps1
```

## 1. Protect the default branch

Needs the GitHub CLI, authenticated with admin on the repo:

```pwsh
pwsh -NoProfile -File setup/Protect-MainBranch.ps1
```

Creates a `main-protection` ruleset on the default branch: require a PR, require
the `Quality gate` check, require review threads resolved, route merges through a merge
queue, block force-pushes and branch deletion. Also enables auto-merge and
delete-branch-on-merge on the repo.

`-WithStrictLayer` adds a second, admin-exempt ruleset (1 code-owner approval,
given after the last push). Run it only once a second identity — e.g. an
AI-maintainer App/PAT per [`AI-Maintainer-Identity.adoc`](AI-Maintainer-Identity.adoc)
— opens PRs; with no other identity it binds nobody.

Each rule posts as its own ruleset, so one rejected rule can't block the rest.
In particular, **`merge_queue` only works on org-owned repos** (public or
private-with-GitHub-Enterprise-Cloud) or Enterprise Cloud generally — GitHub
rejects it outright on a personal/user-owned repo. The script warns and skips
it in that case; the other four protections (no force-push, no deletion,
required PR, required `Quality gate` check) still land.
[GitHub documents merge-queue availability and setup requirements](https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue).

## 2. Enable server-side security settings

The security toggles that live in GitHub's API, not in repo files. Same
requirements (admin + `gh`); every call is idempotent, so re-running is safe:

```pwsh
pwsh -NoProfile -File setup/Enable-RepoSecurity.ps1
```

Turns on native secret scanning + push protection, Dependabot alerts and
automated security fixes, private vulnerability reporting, and a read-only
default workflow token. Pass `-SkipWorkflowTokenReadOnly` if a workflow depends
on the legacy read/write default. Settings that are plan-restricted or already
set warn and are skipped; the script still applies the rest.

## 3. Set up and verify the AI-maintainer identity

Agents must work under their own least-privilege identity, never under your
admin account. [`AI-Maintainer-Identity.adoc`](AI-Maintainer-Identity.adoc) is
the knowledge base; three scripts automate what can be automated:

```pwsh
# Create a least-privilege GitHub App through GitHub's manifest flow.
# One App per locally-run agent.
pwsh -NoProfile -File setup/New-AIMaintainerApp.ps1

# Install the App on this repository, then use the command printed by the
# script to set GH_TOKEN with New-AIMaintainerToken.ps1.

# From the AGENT's shell: verify its credential is a safe identity
# (installation token or fine-grained PAT) WITH repo write/push and WITHOUT
# admin. Fails closed.
pwsh -NoProfile -File setup/Test-AIMaintainerIdentity.ps1
```

Create Apps only for agents *you* run locally (Claude Code, Codex CLI, …).
Vendor-hosted agents use their product's supported source-control integration;
scope it to only the intended repositories.

## Optional: install the bundled AI skills

[`optional-skills/README.adoc`](optional-skills/README.adoc) indexes two
skills: `develop-with-tdd`
(plus the TDD knowledge base behind it) that this repo's docs reference, and
`changelog-entry` for adding high-quality `CHANGELOG.md` entries. If your
agent already has an equivalent, skip it; no need for a second copy. Otherwise
install what you want before the next step deletes the bundle, e.g. for Claude
Code:

```pwsh
Copy-Item -Recurse setup/optional-skills/skills/develop-with-tdd ~/.claude/skills/
Copy-Item -Recurse setup/optional-skills/skills/changelog-entry ~/.claude/skills/
```

## 4. Remove this folder (its own first PR)

Once the steps above succeeded, the folder has served its purpose:

```pwsh
pwsh -NoProfile -File setup/Complete-Setup.ps1
```

Branches, removes `setup/`, and opens a PR whose body fills the repo's PR
template. **Failsafe:** it refuses to run on a template repo (`isTemplate`),
so the template itself never loses its setup tooling — and on a dirty
worktree, so the removal PR contains nothing else.
