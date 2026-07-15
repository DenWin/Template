#Requires -Version 7.0
# Capability flags must be set at DISCOVERY time (-Skip is evaluated then).
$HasAsciidoctor = [bool](Get-Command asciidoctor -ErrorAction SilentlyContinue)

BeforeAll {
    $script:Script = Join-Path $PSScriptRoot 'Test-AsciiDoc.ps1'
    . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
}

Describe 'Test-AsciiDoc' -Tag 'Fast' {
    It 'exits 0 when given no files' {
        Invoke-ScriptFile -Path $script:Script | Should -Be 0
    }
}

Describe 'Test-AsciiDoc (asciidoctor)' -Tag 'Standard' {
    It 'exits 0 for valid AsciiDoc' -Skip:(-not $HasAsciidoctor) {
        $f = Join-Path $TestDrive 'ok.adoc'
        "= Title`n`nSome body text." | Set-Content -LiteralPath $f
        Invoke-ScriptFile -Path $script:Script -Arguments @($f) | Should -Be 0
    }

    It 'exits non-zero when a parse warning occurs' -Skip:(-not $HasAsciidoctor) {
        $f = Join-Path $TestDrive 'bad.adoc'
        "= Title`n`ninclude::does-not-exist.adoc[]" | Set-Content -LiteralPath $f
        Invoke-ScriptFile -Path $script:Script -Arguments @($f) | Should -Not -Be 0
    }
}
