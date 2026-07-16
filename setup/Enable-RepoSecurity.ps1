#Requires -Version 7.0
<#
.SYNOPSIS
    Turn on GitHub's server-side security settings that live in the API, not in
    repo files (secret scanning, Dependabot alerts/fixes, private vuln
    reporting, read-only default workflow token).

.DESCRIPTION
    Run once on a new repo made from this template, then delete the setup/
    folder. Requires the GitHub CLI, authenticated with admin on the repo.
    Every call is idempotent — re-running is safe. Individual settings that fail
    (plan limits, already-set, insufficient scope) warn and do not abort the
    rest; the exit code is non-zero if any failed.

    Complements setup/Protect-MainBranch.ps1 (branch ruleset) and the in-repo
    files (CODEOWNERS, workflows). See setup/README.md.

.PARAMETER SkipWorkflowTokenReadOnly
    Leave the default GITHUB_TOKEN permission untouched. Set this if any workflow
    relies on the legacy read/write default instead of per-job `permissions:`.
#>
[CmdletBinding()]
param(
    [switch]$SkipWorkflowTokenReadOnly
)

Set-StrictMode -Version Latest

function Test-GhCli { [bool](Get-Command gh -ErrorAction SilentlyContinue) }

function Get-SecuritySetting {
    <# The settings to apply, as ordered {Name, Method, Path, Body} records.
       Pure: no side effects, so it is unit-testable. #>
    param([Parameter(Mandatory)][string]$Repo, [switch]$IncludeWorkflowToken)

    $settings = [System.Collections.Generic.List[hashtable]]::new()

    # Native secret scanning + push protection (free on public repos; needs GHAS
    # on private). Push protection blocks the push at the server on a match.
    $settings.Add(@{
            Name       = 'secret scanning + push protection'
            Method     = 'PATCH'
            Path       = "repos/$Repo"
            # Free on public repos; on private/internal it requires GitHub
            # Advanced Security. Skipped with a clear message otherwise.
            PublicOnly = $true
            Body       = @{ security_and_analysis = @{
                    secret_scanning                 = @{ status = 'enabled' }
                    secret_scanning_push_protection = @{ status = 'enabled' }
                } }
        })
    # Dependabot vulnerability alerts.
    $settings.Add(@{ Name = 'Dependabot alerts'; Method = 'PUT'; Path = "repos/$Repo/vulnerability-alerts"; Body = $null })
    # Dependabot automated security-fix PRs.
    $settings.Add(@{ Name = 'Dependabot security updates'; Method = 'PUT'; Path = "repos/$Repo/automated-security-fixes"; Body = $null })
    # Private vulnerability reporting (pairs with a SECURITY.md reporting policy).
    $settings.Add(@{ Name = 'private vulnerability reporting'; Method = 'PUT'; Path = "repos/$Repo/private-vulnerability-reporting"; Body = $null })
    # Actions policy: only allowlisted actions may run, and every `uses:` must be
    # pinned to a full-length commit SHA (zizmor lints this; the platform enforces it).
    $settings.Add(@{
            Name   = 'Actions policy (selected actions + SHA pinning required)'
            Method = 'PUT'
            Path   = "repos/$Repo/actions/permissions"
            Body   = @{ enabled = $true; allowed_actions = 'selected'; sha_pinning_required = $true }
        })
    # Allowlist: GitHub-owned + Marketplace-verified creators, plus the explicit
    # third-party actions this template uses (robust even if unverified).
    $settings.Add(@{
            Name   = 'Actions allowlist (GitHub-owned + verified + pinned third-party)'
            Method = 'PUT'
            Path   = "repos/$Repo/actions/permissions/selected-actions"
            Body   = @{
                github_owned_allowed = $true
                verified_allowed     = $true
                patterns_allowed     = @('gitleaks/gitleaks-action@*')
            }
        })

    if ($IncludeWorkflowToken) {
        # Default GITHUB_TOKEN to read-only; workflows opt into writes per-job.
        $settings.Add(@{
                Name   = 'read-only default workflow token'
                Method = 'PUT'
                Path   = "repos/$Repo/actions/permissions/workflow"
                Body   = @{ default_workflow_permissions = 'read'; can_approve_pull_request_reviews = $false }
            })
    }
    $settings
}

function Invoke-RepoSecurity {
    param([switch]$IncludeWorkflowToken)

    # Return codes are the contract; keep Write-Error non-terminating.
    $ErrorActionPreference = 'Continue'

    if (-not (Test-GhCli)) {
        Write-Error 'GitHub CLI (gh) is not installed. https://cli.github.com/'
        return 1
    }
    $repoInfo = gh repo view --json nameWithOwner, visibility 2>$null | ConvertFrom-Json
    if (-not $repoInfo.nameWithOwner) {
        Write-Error 'Not a GitHub repository, or gh is not authenticated (`gh auth login`).'
        return 1
    }
    $repo = $repoInfo.nameWithOwner
    $isPublic = $repoInfo.visibility -eq 'PUBLIC'

    $failed = 0
    foreach ($s in (Get-SecuritySetting -Repo $repo -IncludeWorkflowToken:$IncludeWorkflowToken)) {
        if ($s.ContainsKey('PublicOnly') -and $s.PublicOnly -and -not $isPublic) {
            # A valid not-applicable result, not a failure.
            Write-Warning "Skipped (needs a public repo or GitHub Advanced Security): $($s.Name)."
            continue
        }
        if ($null -ne $s.Body) {
            ($s.Body | ConvertTo-Json -Depth 8) | gh api --method $s.Method $s.Path --input - 2>$null | Out-Null
        }
        else {
            gh api --method $s.Method $s.Path 2>$null | Out-Null
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not enable: $($s.Name) (already set, plan-restricted, or missing scope)."
            $failed++
        }
        else {
            Write-Information "Enabled: $($s.Name)." -InformationAction Continue
        }
    }

    if ($failed -gt 0) {
        Write-Warning "$failed setting(s) not applied on $repo. Review the warnings above."
        return 1
    }
    Write-Information "Repository security settings applied on $repo." -InformationAction Continue
    return 0
}

# Execute only when run directly, not when dot-sourced by a test.
if ($MyInvocation.InvocationName -ne '.') {
    exit (Invoke-RepoSecurity -IncludeWorkflowToken:(-not $SkipWorkflowTokenReadOnly))
}
