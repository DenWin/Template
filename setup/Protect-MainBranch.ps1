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

.PARAMETER WithStrictLayer
    Also create a second, admin-exempt ruleset: 1 approval from a code owner,
    given after the last push, stale approvals dismissed. Use once a second
    identity (e.g. an AI-maintainer App/PAT) opens PRs — until then the layer
    binds nobody.
#>
[CmdletBinding()]
param(
    [string]$CheckName = 'lint',
    [int]$RequiredApprovals = 0,
    [ValidateSet('MERGE', 'SQUASH', 'REBASE')]
    [string]$MergeMethod = 'SQUASH',
    [switch]$WithStrictLayer
)

Set-StrictMode -Version Latest

function Test-GhCli { [bool](Get-Command gh -ErrorAction SilentlyContinue) }

function Get-ProtectionRuleset {
    <# Build the rulesets-API payloads (pure; no side effects) — one ruleset per
       rule type, posted as separate API calls. GitHub rejects the whole request
       if ANY rule in a ruleset is invalid for the repo (e.g. 'merge_queue' on a
       personal/user-owned repo, which only supports it on org-owned repos or
       Enterprise Cloud) — splitting per-rule means that one incompatible rule
       can't block the rest of the protections from landing. #>
    param(
        [Parameter(Mandatory)][string]$CheckName,
        [Parameter(Mandatory)][int]$RequiredApprovals,
        [Parameter(Mandatory)][string]$MergeMethod
    )
    $target = @{ ref_name = @{ include = @('~DEFAULT_BRANCH'); exclude = @() } }
    @(
        @{
            name        = 'main-protection-deletion'
            target      = 'branch'
            enforcement = 'active'
            conditions  = $target
            rules       = @(@{ type = 'deletion' })
        }
        @{
            name        = 'main-protection-non-fast-forward'
            target      = 'branch'
            enforcement = 'active'
            conditions  = $target
            rules       = @(@{ type = 'non_fast_forward' })
        }
        @{
            name        = 'main-protection-pull-request'
            target      = 'branch'
            enforcement = 'active'
            conditions  = $target
            rules       = @(
                @{
                    type       = 'pull_request'
                    parameters = @{
                        required_approving_review_count   = $RequiredApprovals
                        dismiss_stale_reviews_on_push     = $false
                        require_code_owner_review         = $false
                        require_last_push_approval        = $false
                        # Unresolved review threads block the merge — with
                        # auto-merge on, a review comment holds an agent PR
                        # until it is resolved.
                        required_review_thread_resolution = $true
                    }
                }
            )
        }
        @{
            name        = 'main-protection-required-status-checks'
            target      = 'branch'
            enforcement = 'active'
            conditions  = $target
            rules       = @(
                @{
                    type       = 'required_status_checks'
                    parameters = @{
                        required_status_checks               = @(@{ context = $CheckName })
                        strict_required_status_checks_policy = $false
                    }
                }
            )
        }
        @{
            name        = 'main-protection-merge-queue'
            target      = 'branch'
            enforcement = 'active'
            conditions  = $target
            rules       = @(
                @{
                    type       = 'merge_queue'
                    parameters = @{
                        merge_method                      = $MergeMethod
                        grouping_strategy                 = 'ALLGREEN'
                        max_entries_to_build              = 5
                        min_entries_to_merge              = 1
                        max_entries_to_merge              = 5
                        min_entries_to_merge_wait_minutes = 1
                        check_response_timeout_minutes    = 60
                    }
                }
            )
        }
    )
}

function Get-StrictLayerRuleset {
    <# Build the second, admin-exempt ruleset (pure; no side effects).
       Layered on top of main-protection: rulesets aggregate most-restrictive,
       so everyone EXCEPT the exempt repo admin additionally needs one approval
       from a code owner, given after the last push. Run only once a second
       identity (e.g. an AI-maintainer App/PAT) exists — with no other identity,
       this layer binds nobody. #>
    @{
        name          = 'main-protection-strict'
        target        = 'branch'
        enforcement   = 'active'
        conditions    = @{ ref_name = @{ include = @('~DEFAULT_BRANCH'); exclude = @() } }
        # actor_id 5 = Repository admin role; 'exempt' removes these rules for it.
        bypass_actors = @(@{ actor_id = 5; actor_type = 'RepositoryRole'; bypass_mode = 'exempt' })
        rules         = @(
            @{
                type       = 'pull_request'
                parameters = @{
                    required_approving_review_count   = 1
                    require_code_owner_review         = $true
                    require_last_push_approval        = $true
                    dismiss_stale_reviews_on_push     = $true
                    required_review_thread_resolution = $true
                }
            }
        )
    }
}

function Get-MergeFlowSetting {
    <# Repo-level merge-flow settings (pure; no side effects).
       All three merge methods stay enabled: the merge queue already enforces
       $MergeMethod for the gated path, and a ruleset cannot re-enable a method
       disabled repo-wide — disabling here would also bind bypass actors. #>
    @{
        allow_auto_merge       = $true  # `gh pr merge --auto` queues on green checks
        delete_branch_on_merge = $true
    }
}

function Invoke-BranchProtection {
    param(
        [Parameter(Mandatory)][string]$CheckName,
        [Parameter(Mandatory)][int]$RequiredApprovals,
        [Parameter(Mandatory)][string]$MergeMethod,
        [switch]$WithStrictLayer
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

    $rulesets = Get-ProtectionRuleset -CheckName $CheckName -RequiredApprovals $RequiredApprovals -MergeMethod $MergeMethod
    $failed = @()
    foreach ($ruleset in $rulesets) {
        ($ruleset | ConvertTo-Json -Depth 8) | gh api --method POST "repos/$repo/rulesets" --input - | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Ruleset '$($ruleset.name)' failed (it may already exist, be unsupported on this repo/plan, or you lack admin) — continuing with the rest."
            $failed += $ruleset.name
        }
    }
    $optionalRulesets = @('main-protection-merge-queue')
    $requiredFailures = @($failed | Where-Object { $_ -notin $optionalRulesets })

    if ($failed.Count -eq $rulesets.Count) {
        Write-Error 'All branch-protection rulesets failed; nothing was applied.'
        return 1
    }
    if ($requiredFailures.Count -gt 0) {
        Write-Error "Required branch-protection rulesets failed: $($requiredFailures -join ', ')"
        return 1
    }
    if ($failed.Count -gt 0) {
        Write-Warning "Branch protection partially applied — skipped: $($failed -join ', ')"
    }

    if ($WithStrictLayer) {
        (Get-StrictLayerRuleset | ConvertTo-Json -Depth 8) | gh api --method POST "repos/$repo/rulesets" --input -
        if ($LASTEXITCODE -ne 0) {
            Write-Error 'Base ruleset created, but the strict layer failed (it may already exist).'
            return 1
        }
    }

    (Get-MergeFlowSetting | ConvertTo-Json) | gh api --method PATCH "repos/$repo" --input - | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'Ruleset created, but setting auto-merge/branch-cleanup failed.'
        return 1
    }

    Write-Information "Branch protection + merge flow active on $repo (default branch)." -InformationAction Continue
    return 0
}

# Execute only when run directly, not when dot-sourced by a test.
if ($MyInvocation.InvocationName -ne '.') {
    exit (Invoke-BranchProtection -CheckName $CheckName -RequiredApprovals $RequiredApprovals -MergeMethod $MergeMethod -WithStrictLayer:$WithStrictLayer)
}
