#Requires -Version 7.0
Set-StrictMode -Version Latest

BeforeAll {
    # Dot-source the SUT: defines its functions; the run guard skips execution.
    . (Join-Path $PSScriptRoot 'Protect-MainBranch.ps1')
}

Describe 'Get-ProtectionRuleset' -Tag 'Fast' {
    BeforeAll {
        $script:R = Get-ProtectionRuleset -CheckName 'lint' -RequiredApprovals 0 -MergeMethod 'SQUASH'
    }

    It 'targets the default branch' {
        $script:R.conditions.ref_name.include | Should -Contain '~DEFAULT_BRANCH'
    }

    It 'requires a pull request' {
        ($script:R.rules | Where-Object type -EQ 'pull_request') | Should -Not -BeNullOrEmpty
    }

    It 'requires the given status check' {
        $rsc = ($script:R.rules | Where-Object type -EQ 'required_status_checks').parameters.required_status_checks
        $rsc.context | Should -Contain 'lint'
    }

    It 'blocks force-push and deletion' {
        $script:R.rules.type | Should -Contain 'non_fast_forward'
        $script:R.rules.type | Should -Contain 'deletion'
    }

    It 'routes merges through a merge queue' {
        $script:R.rules.type | Should -Contain 'merge_queue'
    }

    It 'waits at most 1 minute before merging queued entries' {
        ($script:R.rules | Where-Object type -EQ 'merge_queue').parameters.min_entries_to_merge_wait_minutes |
            Should -Be 1
    }

    It 'requires review threads to be resolved (holds auto-merge on open comments)' {
        ($script:R.rules | Where-Object type -EQ 'pull_request').parameters.required_review_thread_resolution |
            Should -BeTrue
    }
}

Describe 'Get-StrictLayerRuleset' -Tag 'Fast' {
    BeforeAll {
        $script:L = Get-StrictLayerRuleset
    }

    It 'exempts the repository admin role' {
        $script:L.bypass_actors.actor_type | Should -Contain 'RepositoryRole'
        $script:L.bypass_actors.bypass_mode | Should -Contain 'exempt'
    }

    It 'requires one code-owner approval given after the last push' {
        $p = ($script:L.rules | Where-Object type -EQ 'pull_request').parameters
        $p.required_approving_review_count | Should -Be 1
        $p.require_code_owner_review | Should -BeTrue
        $p.require_last_push_approval | Should -BeTrue
        $p.dismiss_stale_reviews_on_push | Should -BeTrue
    }

    It 'targets the default branch under a distinct name' {
        $script:L.conditions.ref_name.include | Should -Contain '~DEFAULT_BRANCH'
        $script:L.name | Should -Not -Be 'main-protection'
    }
}

Describe 'Get-MergeFlowSetting' -Tag 'Fast' {
    It 'enables auto-merge and branch cleanup, and touches nothing else' {
        $s = Get-MergeFlowSetting
        $s.allow_auto_merge | Should -BeTrue
        $s.delete_branch_on_merge | Should -BeTrue
        # No merge-method keys: a repo-wide disable would also bind bypass actors.
        $s.Keys | Where-Object { $_ -match 'allow_.*_merge$' -and $_ -ne 'allow_auto_merge' } |
            Should -BeNullOrEmpty
    }
}

Describe 'Invoke-BranchProtection' -Tag 'Fast' {
    It 'returns non-zero when gh is not installed' {
        Mock Test-GhCli { $false }
        Invoke-BranchProtection -CheckName 'lint' -RequiredApprovals 0 -MergeMethod 'SQUASH' 2>$null |
            Should -Be 1
    }
}
