#Requires -Version 7.0
Set-StrictMode -Version Latest

# Capability flags must be set at DISCOVERY time (-Skip is evaluated then).
$HasPSSA = [bool](Get-Module -ListAvailable -Name PSScriptAnalyzer)

BeforeAll {
    $script:Script = Join-Path $PSScriptRoot 'Test-PowerShellScript.ps1'
    . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
}

Describe 'Test-PowerShellScript' -Tag 'Fast' {
    It 'exits 0 when given no files' {
        Invoke-ScriptFile -Path $script:Script | Should -Be 0
    }
}

Describe 'Test-PowerShellScript (PSScriptAnalyzer)' -Tag 'Standard' {
    It 'exits 0 for a clean script' -Skip:(-not $HasPSSA) {
        $f = Join-Path $TestDrive 'clean.ps1'
        "Write-Output 'hello'" | Set-Content -LiteralPath $f
        Invoke-ScriptFile -Path $script:Script -Arguments @($f) | Should -Be 0
    }

    It 'exits non-zero for a Warning-level violation' -Skip:(-not $HasPSSA) {
        $f = Join-Path $TestDrive 'dirty.ps1'
        'gci' | Set-Content -LiteralPath $f  # alias -> PSAvoidUsingCmdletAliases (Warning)
        Invoke-ScriptFile -Path $script:Script -Arguments @($f) | Should -Not -Be 0
    }
}
