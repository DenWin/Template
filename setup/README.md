# One-time repo setup

Tooling to run **once** on a new repo created from this template — then delete
this whole folder.

## Protect the default branch

Needs the GitHub CLI, authenticated with admin on the repo:

```pwsh
pwsh -NoProfile -File setup/Protect-MainBranch.ps1
```

Creates a `main-protection` ruleset on the default branch: require a PR, require
the `lint` check, require review threads resolved, route merges through a merge
queue, block force-pushes and branch deletion. Also enables auto-merge and
delete-branch-on-merge on the repo.

`-WithStrictLayer` adds a second, admin-exempt ruleset (1 code-owner approval,
given after the last push). Run it only once a second identity — e.g. an
AI-maintainer App/PAT per [`AI-Maintainer-Identity.adoc`](AI-Maintainer-Identity.adoc)
— opens PRs; with no other identity it binds nobody.

## Enable server-side security settings

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

## Set up AI-maintainer identities

[`AI-Maintainer-Identity.adoc`](AI-Maintainer-Identity.adoc) is the knowledge
base for giving each AI agent its own least-privilege identity (GitHub App or
fine-grained PAT) instead of running under the owner's admin account.

## Remove this folder

Once protection is on, this folder has served its purpose:

```pwsh
git rm -r setup
git commit -m "Remove one-time setup tooling"
```
