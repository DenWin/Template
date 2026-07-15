#Requires -Version 7.0
BeforeAll {
    # Dot-source the SUT: defines its functions; the run guard skips execution.
    . (Join-Path $PSScriptRoot 'Enable-MergeQueue.ps1')
}

Describe 'Get-MergeQueueRuleset' -Tag 'Fast' {
    BeforeAll {
        $script:R = Get-MergeQueueRuleset -RulesetName 'x' -CheckName 'lint' -MergeMethod 'REBASE'
    }

    It 'targets the default branch' {
        $script:R.conditions.ref_name.include | Should -Contain '~DEFAULT_BRANCH'
    }

    It 'requires the given status check' {
        $rsc = ($script:R.rules | Where-Object type -EQ 'required_status_checks').parameters.required_status_checks
        $rsc.context | Should -Contain 'lint'
    }

    It 'uses the chosen merge method' {
        $mq = ($script:R.rules | Where-Object type -EQ 'merge_queue').parameters
        $mq.merge_method | Should -Be 'REBASE'
    }
}

Describe 'Invoke-EnableMergeQueue' -Tag 'Fast' {
    It 'returns non-zero when gh is not installed' {
        Mock Test-GhCli { $false }
        Invoke-EnableMergeQueue -CheckName 'lint' -RulesetName 'x' -MergeMethod 'SQUASH' 2>$null |
            Should -Be 1
    }

    It 'posts the ruleset to the repo rulesets endpoint on success' {
        Mock Test-GhCli { $true }
        Mock gh {
            if ($args -contains 'view') { 'owner/repo' } else { $global:LASTEXITCODE = 0 }
        }
        Invoke-EnableMergeQueue -CheckName 'lint' -RulesetName 'x' -MergeMethod 'SQUASH' 6>$null |
            Should -Be 0
        Should -Invoke gh -ParameterFilter {
            ($args -contains 'api') -and (($args -join ' ') -match 'repos/owner/repo/rulesets')
        }
    }
}
