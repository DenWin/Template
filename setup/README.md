# One-time repo setup

Tooling to run **once** on a new repo created from this template — then delete
this whole folder.

## Protect the default branch

Needs the GitHub CLI, authenticated with admin on the repo:

```pwsh
pwsh -NoProfile -File setup/Protect-MainBranch.ps1
```

Creates a `main-protection` ruleset on the default branch: require a PR, require
the `lint` check, route merges through a merge queue, and block force-pushes and
branch deletion.

## Remove this folder

Once protection is on, this folder has served its purpose:

```pwsh
git rm -r setup
git commit -m "Remove one-time setup tooling"
```
