#Requires -Version 7.0
<#
.SYNOPSIS
    Finish the one-time setup: remove the setup/ folder and open it as the
    repo's first pull request. Refuses to run on the template repo itself.

.DESCRIPTION
    The last step after bootstrapping a repo from this template — run it once
    Protect-MainBranch.ps1 and Enable-RepoSecurity.ps1 have succeeded and the
    AI-maintainer identity is in place (Test-AIMaintainerIdentity.ps1 from the
    agent's shell). It:

      1. FAILSAFE: aborts if the repo is a template repo (`isTemplate`), so the
         template itself never loses its setup tooling,
      2. aborts on a dirty worktree, so the PR contains only the removal,
      3. branches, `git rm -r setup`, commits, pushes, and opens a PR whose
         body fills the repo's PR template (Evidence included).

    Requires the GitHub CLI, authenticated with push access, run from the
    repo root.

.PARAMETER BranchName
    Branch for the removal PR.
#>
[CmdletBinding()]
param(
    [string]$BranchName = 'chore/remove-setup'
)

Set-StrictMode -Version Latest

function Test-GhCli { [bool](Get-Command gh -ErrorAction SilentlyContinue) }

function Test-RemovalAllowed {
    <# The template failsafe (pure; no side effects): a template repo keeps its
       setup/ folder — only repos CREATED from it remove theirs. #>
    param([Parameter(Mandatory)][object]$RepoInfo)
    if ($RepoInfo.isTemplate) {
        return @{
            Allowed = $false
            Reason  = "$($RepoInfo.nameWithOwner) is a template repo — its setup/ folder must stay for the repos bootstrapped from it."
        }
    }
    @{ Allowed = $true; Reason = '' }
}

function Get-RemovalPullRequestBody {
    <# PR body honoring .github/pull_request_template.md — every section
       filled, Evidence mandatory (pure; no side effects). #>
    @'
## Goal

Remove the one-time `setup/` tooling — it has served its purpose: branch
protection, server-side security settings, and the AI-maintainer identity are
in place.

## Scope

Deletes `setup/` only. No other file changes.

## Risk & rollback

Low — the folder is inert documentation/tooling once setup ran; nothing
references it at runtime. Rollback: revert this PR (the folder is preserved in
history and in the upstream template).

## Evidence

- `setup/Protect-MainBranch.ps1` and `setup/Enable-RepoSecurity.ps1` completed
  successfully against this repo (rulesets and security settings visible in
  repo settings).
- `setup/Test-AIMaintainerIdentity.ps1` passed from the agent shell.
- CI (`lint`) validates this PR like any other.
'@
}

function Invoke-SetupRemoval {
    param([string]$BranchName = 'chore/remove-setup')

    # Return codes are the contract; keep Write-Error non-terminating.
    $ErrorActionPreference = 'Continue'

    if (-not (Test-GhCli)) {
        Write-Error 'GitHub CLI (gh) is not installed. https://cli.github.com/'
        return 1
    }
    $repoInfo = gh repo view --json isTemplate,nameWithOwner 2>$null | ConvertFrom-Json
    if (-not $repoInfo) {
        Write-Error 'Not a GitHub repository, or gh is not authenticated (`gh auth login`).'
        return 1
    }

    $verdict = Test-RemovalAllowed -RepoInfo $repoInfo
    if (-not $verdict.Allowed) {
        Write-Error "FAILSAFE: $($verdict.Reason)"
        return 1
    }

    if (git status --porcelain) {
        Write-Error 'Worktree is not clean — commit or stash first, so the removal PR contains nothing else.'
        return 1
    }

    git switch -c $BranchName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Could not create branch '$BranchName' (does it already exist?)."
        return 1
    }
    git rm -r -q -- setup
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'git rm -r setup failed — is the working directory the repo root?'
        return 1
    }
    git commit -m 'Remove one-time setup tooling'
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'Commit failed.'
        return 1
    }
    git push -u origin $BranchName
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'Push failed — check your remote and permissions.'
        return 1
    }
    $prUrl = gh pr create --title 'Remove one-time setup tooling' --body (Get-RemovalPullRequestBody)
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'Branch pushed, but opening the PR failed — open it manually (`gh pr create`).'
        return 1
    }

    Write-Information "Setup removal PR opened: $prUrl" -InformationAction Continue
    return 0
}

# Execute only when run directly, not when dot-sourced by a test.
if ($MyInvocation.InvocationName -ne '.') {
    exit (Invoke-SetupRemoval -BranchName $BranchName)
}
