#Requires -Version 7.0
Set-StrictMode -Version Latest

BeforeAll {
    # Dot-source the SUT: defines its functions; the run guard skips execution.
    . (Join-Path $PSScriptRoot '..' 'Complete-Setup.ps1')
}

Describe 'Test-RemovalAllowed' -Tag 'Fast' {
    It 'blocks removal on a template repo, naming the failsafe' {
        $v = Test-RemovalAllowed -RepoInfo @{ isTemplate = $true; nameWithOwner = 'DenWin/Template' }
        $v.Allowed | Should -BeFalse
        $v.Reason | Should -Match 'template'
    }

    It 'allows removal on a repo created from the template' {
        (Test-RemovalAllowed -RepoInfo @{ isTemplate = $false; nameWithOwner = 'DenWin/NewRepo' }).Allowed |
            Should -BeTrue
    }
}

Describe 'Get-RemovalPullRequestBody' -Tag 'Fast' {
    BeforeAll {
        $script:Body = Get-RemovalPullRequestBody
    }

    It 'fills every section the PR template demands' {
        foreach ($section in '## Goal', '## Scope', '## Risk & rollback', '## Evidence') {
            $script:Body | Should -Match ([regex]::Escape($section))
        }
    }

    It 'cites the completed setup scripts as Evidence' {
        $script:Body | Should -Match 'Protect-MainBranch'
        $script:Body | Should -Match 'Enable-RepoSecurity'
    }
}

Describe 'Invoke-SetupRemoval' -Tag 'Fast' {
    It 'returns non-zero when gh is not installed' {
        Mock Test-GhCli { $false }
        Invoke-SetupRemoval 2>$null | Should -Be 1
    }

    It 'refuses to touch a template repo — no git mutation happens' {
        Mock Test-GhCli { $true }
        Mock gh { '{"isTemplate":true,"nameWithOwner":"DenWin/Template"}' }
        Mock git { $global:LASTEXITCODE = 0 }
        Invoke-SetupRemoval 2>$null | Should -Be 1
        Should -Invoke git -Exactly -Times 0
    }

    It 'refuses on a dirty worktree so the PR holds only the removal' {
        Mock Test-GhCli { $true }
        Mock gh { '{"isTemplate":false,"nameWithOwner":"o/r"}' }
        Mock git {
            $global:LASTEXITCODE = 0
            if ($args -contains 'status') { return ' M some/file.ps1' }
        }
        Invoke-SetupRemoval 2>$null | Should -Be 1
        Should -Invoke git -ParameterFilter { $args -contains 'rm' } -Exactly -Times 0
    }

    It 'removes setup/, pushes a branch, and opens the PR on the happy path' {
        Mock Test-GhCli { $true }
        Mock gh {
            $global:LASTEXITCODE = 0
            if ($args -contains 'view') { return '{"isTemplate":false,"nameWithOwner":"o/r"}' }
            if ($args -contains 'create') { return 'https://github.com/o/r/pull/1' }
        }
        Mock git {
            $global:LASTEXITCODE = 0
            if ($args -contains 'status') { return '' }
        }
        Invoke-SetupRemoval | Should -Be 0
        Should -Invoke git -ParameterFilter { $args -contains 'rm' } -Exactly -Times 1
        Should -Invoke git -ParameterFilter { $args -contains 'push' } -Exactly -Times 1
        Should -Invoke gh -ParameterFilter { $args -contains 'create' } -Exactly -Times 1
    }
}
