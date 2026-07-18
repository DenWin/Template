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

    It 'describes both setup removal and permanent-document cleanup' {
        $script:Body | Should -Match 'permanent'
        $script:Body | Should -Match 'reference'
    }
}

Describe 'Remove-TemplateOnlyDocumentation' -Tag 'Fast' {
    It 'removes marked lines and blocks while preserving unrelated content' {
        $root = Join-Path $TestDrive 'repo'
        New-Item -ItemType Directory -Path $root | Out-Null
        $doc = Join-Path $root 'AGENTS.md'
        @'
# Keep
keep this
remove this <!-- setup-teardown:template-only -->
remove this hash-marked line # setup-teardown:template-only
<!-- setup-teardown:template-only:start -->
remove this block and its setup/local-link.md reference
<!-- setup-teardown:template-only:end -->
keep that
'@ | Set-Content -Path $doc

        $changed = Remove-TemplateOnlyDocumentation -RepositoryRoot $root -RelativePaths @('AGENTS.md')

        $changed | Should -Be @('AGENTS.md')
        $result = Get-Content -Path $doc -Raw
        $result | Should -Match 'keep this'
        $result | Should -Match 'keep that'
        $result | Should -Not -Match 'template-only|remove this|setup/'
    }

    It 'returns no path when a document needs no cleanup' {
        $root = Join-Path $TestDrive 'clean-repo'
        New-Item -ItemType Directory -Path $root | Out-Null
        Set-Content -Path (Join-Path $root 'README.md') -Value '# already clean'

        Remove-TemplateOnlyDocumentation -RepositoryRoot $root -RelativePaths @('README.md') |
            Should -BeNullOrEmpty
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
        Mock Test-AIMaintainerPrecondition { $true }
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

    It 'stops before git mutation when the AI-maintainer identity is not safe' {
        Mock Test-GhCli { $true }
        Mock gh { '{"isTemplate":false,"nameWithOwner":"o/r"}' }
        Mock Test-AIMaintainerPrecondition { $false }
        Mock git {
            $global:LASTEXITCODE = 0
            if ($args -contains 'status') { return '' }
        }

        Invoke-SetupRemoval 2>$null | Should -Be 1

        Should -Invoke git -ParameterFilter { $args -contains 'switch' } -Exactly -Times 0
        Should -Invoke git -ParameterFilter { $args -contains 'rm' } -Exactly -Times 0
    }

    It 'verifies identity, cleans permanent docs, removes setup, and opens the PR' {
        $script:Trace = [System.Collections.Generic.List[string]]::new()
        Mock Test-GhCli { $true }
        Mock Test-AIMaintainerPrecondition {
            $script:Trace.Add('identity')
            $true
        }
        Mock Remove-TemplateOnlyDocumentation {
            $script:Trace.Add('docs')
            @('AGENTS.md', 'README.md')
        }
        Mock gh {
            $global:LASTEXITCODE = 0
            if ($args -contains 'view') { return '{"isTemplate":false,"nameWithOwner":"o/r"}' }
            if ($args -contains 'create') { return 'https://github.com/o/r/pull/1' }
        }
        Mock git {
            $global:LASTEXITCODE = 0
            if ($args -contains 'switch') { $script:Trace.Add('switch') }
            if ($args -contains 'status') { return '' }
        }

        Invoke-SetupRemoval | Should -Be 0

        $script:Trace.IndexOf('identity') | Should -BeLessThan $script:Trace.IndexOf('switch')
        $script:Trace.IndexOf('docs') | Should -BeGreaterThan $script:Trace.IndexOf('switch')
        Should -Invoke Remove-TemplateOnlyDocumentation -Exactly -Times 1
        Should -Invoke git -ParameterFilter { $args -contains 'rm' } -Exactly -Times 1
        Should -Invoke git -ParameterFilter {
            $args[0] -eq 'add' -and
            $args -contains 'AGENTS.md' -and
            $args -contains 'README.md'
        } -Exactly -Times 1
        Should -Invoke git -ParameterFilter { $args -contains 'push' } -Exactly -Times 1
        Should -Invoke gh -ParameterFilter { $args -contains 'create' } -Exactly -Times 1
    }
}
