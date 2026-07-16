#Requires -Version 7.0
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
}

Describe 'Invoke-BranchProtection' -Tag 'Fast' {
    It 'returns non-zero when gh is not installed' {
        Mock Test-GhCli { $false }
        Invoke-BranchProtection -CheckName 'lint' -RequiredApprovals 0 -MergeMethod 'SQUASH' 2>$null |
            Should -Be 1
    }
}
