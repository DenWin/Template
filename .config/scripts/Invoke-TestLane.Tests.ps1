#Requires -Version 7.0
# Capability flags must be set at DISCOVERY time (-Skip is evaluated then).
$HasPester = [bool](Get-Module -ListAvailable -Name Pester |
        Where-Object { $_.Version -ge [version]'5.0.0' })

BeforeAll {
    $script:Script = Join-Path $PSScriptRoot 'Invoke-TestLane.ps1'
    . (Join-Path $PSScriptRoot '_TestHelpers.ps1')

    # Copy the script into an isolated fake repo so its repo-root scan
    # ($PSScriptRoot/../..) sees only what the test sets up — never the real repo.
    function Get-IsolatedScript {
        $root = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        $dir = Join-Path $root '.config/scripts'
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        $copy = Join-Path $dir 'Invoke-TestLane.ps1'
        Copy-Item -LiteralPath $script:Script -Destination $copy
        [pscustomobject]@{ Root = $root; Script = $copy }
    }
}

Describe 'Invoke-TestLane' -Tag 'Fast' {
    It 'rejects an invalid lane' {
        Invoke-ScriptFile -Path $script:Script -Arguments @('-Lane', 'Bogus') | Should -Not -Be 0
    }
}

Describe 'Invoke-TestLane (isolated)' -Tag 'Standard' {
    It 'no-ops (exit 0) when the repo has no tests' {
        $iso = Get-IsolatedScript
        Invoke-ScriptFile -Path $iso.Script -Arguments @('-Lane', 'Fast') | Should -Be 0
    }

    It 'exits 0 for a passing tagged test' -Skip:(-not $HasPester) {
        $iso = Get-IsolatedScript
        $testsDir = Join-Path $iso.Root 'tests'
        New-Item -ItemType Directory -Path $testsDir -Force | Out-Null
        "Describe 'x' -Tag 'Fast' { It 'passes' { 1 | Should -Be 1 } }" |
            Set-Content -LiteralPath (Join-Path $testsDir 'Dummy.Tests.ps1')
        Invoke-ScriptFile -Path $iso.Script -Arguments @('-Lane', 'Fast') | Should -Be 0
    }

    It 'exits non-zero for a failing tagged test' -Skip:(-not $HasPester) {
        $iso = Get-IsolatedScript
        $testsDir = Join-Path $iso.Root 'tests'
        New-Item -ItemType Directory -Path $testsDir -Force | Out-Null
        "Describe 'x' -Tag 'Fast' { It 'fails' { 1 | Should -Be 2 } }" |
            Set-Content -LiteralPath (Join-Path $testsDir 'Dummy.Tests.ps1')
        Invoke-ScriptFile -Path $iso.Script -Arguments @('-Lane', 'Fast') | Should -Not -Be 0
    }
}
