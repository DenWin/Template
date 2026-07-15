#Requires -Version 7.0
BeforeAll {
    # Dot-source the SUT: defines its functions; the run guard skips execution.
    . (Join-Path $PSScriptRoot 'Initialize-DevEnvironment.ps1')
}

Describe 'Invoke-Initialize' -Tag 'Fast' {
    BeforeEach {
        # Happy-path defaults; individual tests override one seam at a time.
        Mock Test-Command { $true }                                    # git + uv present
        Mock Test-Elevated { $false }
        Mock Write-Warning { }
        Mock Get-Module { @([pscustomobject]@{ Version = [version]'9.9.9' }) } # present
        Mock Invoke-DevModuleInstall { }
        Mock Invoke-PreCommitInstall { }
        Mock Write-Information { }
    }

    It 'returns 1 when git is missing' {
        Mock Test-Command { $false } -ParameterFilter { $Name -eq 'git' }
        Invoke-Initialize 2>$null | Should -Be 1
    }

    It 'returns 1 when uv is missing' {
        Mock Test-Command { $false } -ParameterFilter { $Name -eq 'uv' }
        Invoke-Initialize 2>$null | Should -Be 1
    }

    It 'warns when the shell is elevated' {
        Mock Test-Elevated { $true }
        Invoke-Initialize | Out-Null
        Should -Invoke Write-Warning
    }

    It 'installs a module when it is absent' {
        Mock Get-Module { @() }
        Invoke-Initialize | Out-Null
        Should -Invoke Invoke-DevModuleInstall
    }

    It 'skips install when the module is already present' {
        Invoke-Initialize | Out-Null
        Should -Invoke Invoke-DevModuleInstall -Times 0
    }
}
