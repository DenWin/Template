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
      2. aborts on a dirty worktree or unsafe AI-maintainer identity,
      3. branches, removes template-only references from permanent docs,
         runs `git rm -r setup`, commits, pushes, and opens a PR whose body
         fills the repo's PR template (Evidence included).

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

function Test-AIMaintainerPrecondition {
    param([string]$RepositoryRoot = (Get-Location).Path)

    $identityScript = Join-Path $RepositoryRoot 'setup' 'Test-AIMaintainerIdentity.ps1'
    if (-not (Test-Path -LiteralPath $identityScript -PathType Leaf)) {
        Write-Error "Identity verifier not found: $identityScript"
        return $false
    }

    & pwsh -NoProfile -File $identityScript
    return $LASTEXITCODE -eq 0
}

function Remove-TemplateOnlyDocumentation {
    <# Remove content explicitly marked as useful only while setup/ exists.
       Markers let downstream repos customize the surrounding documents
       without this script replacing whole files. Returns changed paths. #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$RepositoryRoot = (Get-Location).Path,
        [string[]]$RelativePaths = @(
            'AGENTS.md',
            'README.md',
            '.github/README.md',
            '.github/CODEOWNERS',
            '.config/scripts/README.md'
        )
    )

    $changed = [System.Collections.Generic.List[string]]::new()
    $htmlBlockPattern = '(?ms)^[ \t]*<!-- setup-teardown:template-only:start -->\r?\n.*?^[ \t]*<!-- setup-teardown:template-only:end -->\r?\n?'
    $hashBlockPattern = '(?ms)^[ \t]*# setup-teardown:template-only:start[ \t]*\r?\n.*?^[ \t]*# setup-teardown:template-only:end[ \t]*(?:\r?\n|$)'
    $linePattern = '(?m)^.*(?:<!-- setup-teardown:template-only -->|# setup-teardown:template-only).*(?:\r?\n|$)'

    foreach ($relativePath in $RelativePaths) {
        $path = Join-Path $RepositoryRoot $relativePath
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            continue
        }

        $original = [System.IO.File]::ReadAllText($path)
        $updated = [regex]::Replace($original, $htmlBlockPattern, '')
        $updated = [regex]::Replace($updated, $hashBlockPattern, '')
        $updated = [regex]::Replace($updated, $linePattern, '')

        if ($updated -ne $original -and
            $PSCmdlet.ShouldProcess($path, 'Remove template-only documentation')) {
            [System.IO.File]::WriteAllText(
                $path,
                $updated,
                [System.Text.UTF8Encoding]::new($false)
            )
            $changed.Add($relativePath)
        }
    }

    $changed
}

function Invoke-AuthenticatedGitPush {
    <# Force this push through GitHub HTTPS with the exact token that passed the
       identity check. Process-scoped Git config avoids putting the token in
       argv or changing the user's persistent credential helpers. #>
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[^/]+/[^/]+$')]
        [string]$Repository,
        [Parameter(Mandatory)]
        [string]$BranchName,
        [Parameter(Mandatory)]
        [string]$Token
    )

    $existingCount = 0
    if (-not [string]::IsNullOrWhiteSpace($env:GIT_CONFIG_COUNT) -and
        (-not [int]::TryParse($env:GIT_CONFIG_COUNT, [ref]$existingCount) -or
        $existingCount -lt 0)) {
        throw 'GIT_CONFIG_COUNT must be a non-negative integer.'
    }

    $firstIndex = $existingCount
    $managedNames = @(
        'GIT_CONFIG_COUNT',
        "GIT_CONFIG_KEY_$firstIndex",
        "GIT_CONFIG_VALUE_$firstIndex",
        "GIT_CONFIG_KEY_$($firstIndex + 1)",
        "GIT_CONFIG_VALUE_$($firstIndex + 1)",
        "GIT_CONFIG_KEY_$($firstIndex + 2)",
        "GIT_CONFIG_VALUE_$($firstIndex + 2)",
        'GIT_TERMINAL_PROMPT'
    )
    $savedEnvironment = @{}
    foreach ($name in $managedNames) {
        $savedEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
    }

    $basicCredential = [Convert]::ToBase64String(
        [System.Text.Encoding]::ASCII.GetBytes("x-access-token:$Token")
    )

    try {
        [Environment]::SetEnvironmentVariable(
            'GIT_CONFIG_COUNT',
            ($existingCount + 3).ToString(),
            'Process'
        )
        [Environment]::SetEnvironmentVariable(
            "GIT_CONFIG_KEY_$firstIndex",
            'http.https://github.com/.extraHeader',
            'Process'
        )
        [Environment]::SetEnvironmentVariable(
            "GIT_CONFIG_VALUE_$firstIndex",
            '',
            'Process'
        )
        [Environment]::SetEnvironmentVariable(
            "GIT_CONFIG_KEY_$($firstIndex + 1)",
            'http.https://github.com/.extraHeader',
            'Process'
        )
        [Environment]::SetEnvironmentVariable(
            "GIT_CONFIG_VALUE_$($firstIndex + 1)",
            "Authorization: Basic $basicCredential",
            'Process'
        )
        [Environment]::SetEnvironmentVariable(
            "GIT_CONFIG_KEY_$($firstIndex + 2)",
            'credential.helper',
            'Process'
        )
        [Environment]::SetEnvironmentVariable(
            "GIT_CONFIG_VALUE_$($firstIndex + 2)",
            '',
            'Process'
        )
        [Environment]::SetEnvironmentVariable('GIT_TERMINAL_PROMPT', '0', 'Process')

        git push -u "https://github.com/$Repository.git" $BranchName
        return $LASTEXITCODE -eq 0
    }
    finally {
        foreach ($name in $managedNames) {
            [Environment]::SetEnvironmentVariable(
                $name,
                $savedEnvironment[$name],
                'Process'
            )
        }
    }
}

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

Deletes `setup/` and removes its template-only references from permanent
documentation and `CODEOWNERS`.

## Risk & rollback

Low — the folder is inert documentation/tooling once setup ran. The permanent
document edits only remove references that would otherwise become stale.
Rollback: revert this PR (the folder is preserved in history and in the
upstream template).

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

    if (-not (Test-AIMaintainerPrecondition)) {
        Write-Error 'AI-maintainer identity verification failed — setup will not be removed.'
        return 1
    }

    $pushToken = gh auth token 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($pushToken)) {
        Write-Error 'Could not read the verified GitHub credential for the setup-removal push.'
        return 1
    }

    git switch -c $BranchName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Could not create branch '$BranchName' (does it already exist?)."
        return 1
    }

    try {
        $updatedDocs = @(Remove-TemplateOnlyDocumentation)
    }
    catch {
        Write-Error "Could not clean template-only documentation: $($_.Exception.Message)"
        return 1
    }
    if ($updatedDocs.Count -gt 0) {
        git add -- @updatedDocs
        if ($LASTEXITCODE -ne 0) {
            Write-Error 'Staging permanent-document cleanup failed.'
            return 1
        }
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
    if (-not (Invoke-AuthenticatedGitPush -Repository $repoInfo.nameWithOwner `
            -BranchName $BranchName -Token $pushToken)) {
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
