#Requires -Version 7.0
<#
.SYNOPSIS
    Create a merge-queue ruleset on this repo's default branch.

.DESCRIPTION
    Run once per repo, AFTER the first push and at least one CI run (so the
    required status check exists). Requires the GitHub CLI, authenticated with
    permission to manage rulesets.

    The ruleset requires the CI check (default 'lint') and routes merges through
    a merge queue, so the full check set runs on the queued commit before it
    lands.

.PARAMETER CheckName
    Status-check context that must pass. Must match the CI job name
    (lint.yml job -> `name: lint`).

.PARAMETER MergeMethod
    How the queue merges entries.

.NOTES
    verify: the merge_queue parameter schema against the current GitHub REST
    rulesets API on first run.
#>
[CmdletBinding()]
param(
    [string]$CheckName = 'lint',
    [string]$RulesetName = 'merge-queue',
    [ValidateSet('MERGE', 'SQUASH', 'REBASE')]
    [string]$MergeMethod = 'SQUASH'
)

function Test-GhCli { [bool](Get-Command gh -ErrorAction SilentlyContinue) }

function Get-MergeQueueRuleset {
    <# Build the rulesets-API payload (pure; no side effects). #>
    param(
        [Parameter(Mandatory)][string]$RulesetName,
        [Parameter(Mandatory)][string]$CheckName,
        [Parameter(Mandatory)][string]$MergeMethod
    )
    @{
        name        = $RulesetName
        target      = 'branch'
        enforcement = 'active'
        conditions  = @{ ref_name = @{ include = @('~DEFAULT_BRANCH'); exclude = @() } }
        rules       = @(
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
            @{
                type       = 'required_status_checks'
                parameters = @{
                    required_status_checks               = @(@{ context = $CheckName })
                    strict_required_status_checks_policy = $false
                }
            }
        )
    }
}

function Invoke-EnableMergeQueue {
    param(
        [Parameter(Mandatory)][string]$CheckName,
        [Parameter(Mandatory)][string]$RulesetName,
        [Parameter(Mandatory)][string]$MergeMethod
    )

    # Return codes are the contract; keep Write-Error non-terminating even under
    # a caller running $ErrorActionPreference = 'Stop'.
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

    $json = Get-MergeQueueRuleset -RulesetName $RulesetName -CheckName $CheckName -MergeMethod $MergeMethod |
        ConvertTo-Json -Depth 8
    $json | gh api --method POST "repos/$repo/rulesets" --input -
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create ruleset (already exists, or check name '$CheckName' mismatch)."
        return 1
    }

    Write-Information "Merge-queue ruleset '$RulesetName' active on $repo." -InformationAction Continue
    return 0
}

# Execute only when run directly, not when dot-sourced by a test.
if ($MyInvocation.InvocationName -ne '.') {
    exit (Invoke-EnableMergeQueue -CheckName $CheckName -RulesetName $RulesetName -MergeMethod $MergeMethod)
}
