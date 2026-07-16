#Requires -Version 7.0
Set-StrictMode -Version Latest

# Capability flag at DISCOVERY time (-Skip is evaluated then).
$HasPSSA = [bool](Get-Module -ListAvailable -Name PSScriptAnalyzer)

BeforeAll {
    # Exercise the rule through the real hook in a CHILD process. This tests the
    # public boundary (what CI runs) and avoids in-process PSScriptAnalyzer state
    # leaking between test files in one Pester session.
    $script:Hook = Join-Path $PSScriptRoot '..' 'scripts' 'Test-PowerShellScript.ps1' |
        Resolve-Path | Select-Object -ExpandProperty Path

    function Invoke-Hook {
        param([string]$Content, [string]$Extension = '.ps1')
        $file = Join-Path ([IO.Path]::GetTempPath()) ('mrsm-{0}{1}' -f [guid]::NewGuid(), $Extension)
        Set-Content -LiteralPath $file -Value $Content
        try {
            $output = & pwsh -NoProfile -File $script:Hook $file 2>&1 | Out-String
            [pscustomobject]@{ Exit = $LASTEXITCODE; Output = $output }
        }
        finally { Remove-Item -LiteralPath $file -ErrorAction SilentlyContinue }
    }
}

Describe 'Measure-RequireStrictMode (via the hook)' -Tag 'Fast' -Skip:(-not $HasPSSA) {
    It 'fails a script that omits Set-StrictMode, naming the rule' {
        $r = Invoke-Hook -Content 'Write-Output 1'
        $r.Exit | Should -Be 1
        $r.Output | Should -Match 'Measure-RequireStrictMode'
    }

    It 'passes a script that calls Set-StrictMode' {
        (Invoke-Hook -Content "Set-StrictMode -Version Latest`nWrite-Output 1").Exit | Should -Be 0
    }

    It 'exempts data files (*.psd1)' {
        (Invoke-Hook -Content '@{ Answer = 42 }' -Extension '.psd1').Exit | Should -Be 0
    }
}
