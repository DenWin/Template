#Requires -Version 7.0
<#
.SYNOPSIS
    Protect the default branch with a ruleset (PR + lint check + merge queue,
    no force-push/deletion).

.DESCRIPTION
    Run once on a new repo made from this template, then delete the setup/
    folder. Requires the GitHub CLI, authenticated with admin on the repo.

.PARAMETER CheckName
    Required status-check context (must match the CI job name, lint.yml -> lint).

.PARAMETER RequiredApprovals
    PR approvals required before merge (0 suits a solo repo).

.PARAMETER MergeMethod
    How the merge queue merges entries.
#>
[CmdletBinding()]
param(
    [string]$CheckName = 'lint',
    [int]$RequiredApprovals = 0,
    [ValidateSet('MERGE', 'SQUASH', 'REBASE')]
    [string]$MergeMethod = 'SQUASH'
)

function Test-GhCli { [bool](Get-Command gh -ErrorAction SilentlyContinue) }

function Get-ProtectionRuleset {
    <# Build the rulesets-API payload (pure; no side effects). #>
    param(
        [Parameter(Mandatory)][string]$CheckName,
        [Parameter(Mandatory)][int]$RequiredApprovals,
        [Parameter(Mandatory)][string]$MergeMethod
    )
    @{
        name        = 'main-protection'
        target      = 'branch'
        enforcement = 'active'
        conditions  = @{ ref_name = @{ include = @('~DEFAULT_BRANCH'); exclude = @() } }
        rules       = @(
            @{ type = 'deletion' }
            @{ type = 'non_fast_forward' }
            @{
                type       = 'pull_request'
                parameters = @{
                    required_approving_review_count   = $RequiredApprovals
                    dismiss_stale_reviews_on_push     = $false
                    require_code_owner_review         = $false
                    require_last_push_approval        = $false
                    required_review_thread_resolution = $false
                }
            }
            @{
                type       = 'required_status_checks'
                parameters = @{
                    required_status_checks               = @(@{ context = $CheckName })
                    strict_required_status_checks_policy = $false
                }
            }
            @{
                type       = 'merge_queue'
                parameters = @{
                    merge_method                      = $MergeMethod
                    grouping_strategy                 = 'ALLGREEN'
                    max_entries_to_build              = 5
                    min_entries_to_merge              = 1
                    max_entries_to_merge              = 5
                    min_entries_to_merge_wait_minutes = 5
                    check_response_timeout_minutes    = 60
                }
            }
        )
    }
}

function Invoke-BranchProtection {
    param(
        [Parameter(Mandatory)][string]$CheckName,
        [Parameter(Mandatory)][int]$RequiredApprovals,
        [Parameter(Mandatory)][string]$MergeMethod
    )

    # Return codes are the contract; keep Write-Error non-terminating.
    $ErrorActionPreference = 'Continue'

    if (-not (Test-GhCli)) {
        Write-Error 'GitHub CLI (gh) is not installed. https://cli.github.com/'
        return 1
    }

    $repo = gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>$null
    if (-not $repo) {
        Write-Error 'Not a GitHub repository, or gh is not authenticated (`gh auth login`).'
        return 1
    }

    $json = Get-ProtectionRuleset -CheckName $CheckName -RequiredApprovals $RequiredApprovals -MergeMethod $MergeMethod |
        ConvertTo-Json -Depth 8
    $json | gh api --method POST "repos/$repo/rulesets" --input -
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'Failed to create ruleset (it may already exist, or you lack admin on the repo).'
        return 1
    }

    Write-Information "Branch protection active on $repo (default branch)." -InformationAction Continue
    return 0
}

# Execute only when run directly, not when dot-sourced by a test.
if ($MyInvocation.InvocationName -ne '.') {
    exit (Invoke-BranchProtection -CheckName $CheckName -RequiredApprovals $RequiredApprovals -MergeMethod $MergeMethod)
}
