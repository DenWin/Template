#Requires -Version 7.0
Set-StrictMode -Version Latest

BeforeAll {
    # Dot-source the SUT: defines its functions; the run guard skips execution.
    . (Join-Path $PSScriptRoot '..' 'Protect-MainBranch.ps1')
}

Describe 'Get-ProtectionRuleset' -Tag 'Fast' {
    BeforeAll {
        $script:Rs = Get-ProtectionRuleset -CheckName 'lint' -RequiredApprovals 0 -MergeMethod 'SQUASH'
        $script:AllRules = $script:Rs.rules
    }

    It 'returns one ruleset per rule, each targeting the default branch' {
        $script:Rs.Count | Should -Be 5
        $script:Rs | ForEach-Object { $_.conditions.ref_name.include | Should -Contain '~DEFAULT_BRANCH' }
    }

    It 'gives every ruleset a unique name' {
        ($script:Rs.name | Sort-Object -Unique).Count | Should -Be $script:Rs.Count
    }

    It 'requires a pull request' {
        ($script:AllRules | Where-Object type -EQ 'pull_request') | Should -Not -BeNullOrEmpty
    }

    It 'requires the given status check' {
        $rsc = ($script:AllRules | Where-Object type -EQ 'required_status_checks').parameters.required_status_checks
        $rsc.context | Should -Contain 'lint'
    }

    It 'blocks force-push and deletion' {
        $script:AllRules.type | Should -Contain 'non_fast_forward'
        $script:AllRules.type | Should -Contain 'deletion'
    }

    It 'routes merges through a merge queue, isolated in its own ruleset' {
        $script:AllRules.type | Should -Contain 'merge_queue'
        ($script:Rs | Where-Object { $_.rules.type -contains 'merge_queue' }).rules.Count | Should -Be 1
    }

    It 'requires review threads to be resolved (holds auto-merge on open comments)' {
        ($script:AllRules | Where-Object type -EQ 'pull_request').parameters.required_review_thread_resolution |
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

    It 'keeps applying the rest when one ruleset (e.g. merge_queue) is rejected' {
        $script:RulesetPostCalls = 0
        Mock Test-GhCli { $true }
        Mock gh {
            if ($args -contains 'view') { return 'owner/repo' }
            if (($args -join ' ') -match 'repos/.*/rulesets') {
                $script:RulesetPostCalls++
                if ($script:RulesetPostCalls -eq 5) { $global:LASTEXITCODE = 1; return }
            }
            $global:LASTEXITCODE = 0
        }
        Invoke-BranchProtection -CheckName 'lint' -RequiredApprovals 0 -MergeMethod 'SQUASH' 3>$null |
            Should -Be 0
    }

    It 'returns non-zero only when every ruleset is rejected' {
        Mock Test-GhCli { $true }
        Mock gh {
            if ($args -contains 'view') { return 'owner/repo' }
            $global:LASTEXITCODE = 1
        }
        Invoke-BranchProtection -CheckName 'lint' -RequiredApprovals 0 -MergeMethod 'SQUASH' 2>$null 3>$null |
            Should -Be 1
    }

    It 'returns non-zero when a required ruleset (not merge_queue) is rejected' {
        $script:RulesetPostCalls = 0
        Mock Test-GhCli { $true }
        Mock gh {
            if ($args -contains 'view') { return 'owner/repo' }
            if (($args -join ' ') -match 'repos/.*/rulesets') {
                $script:RulesetPostCalls++
                if ($script:RulesetPostCalls -eq 3) { $global:LASTEXITCODE = 1; return }
            }
            $global:LASTEXITCODE = 0
        }
        Invoke-BranchProtection -CheckName 'lint' -RequiredApprovals 0 -MergeMethod 'SQUASH' 2>$null 3>$null |
            Should -Be 1
    }
}
