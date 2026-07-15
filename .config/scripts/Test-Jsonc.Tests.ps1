#Requires -Version 7.0
BeforeAll {
    $script:Script = Join-Path $PSScriptRoot 'Test-Jsonc.ps1'
    . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
}

Describe 'Test-Jsonc' -Tag 'Fast' {
    It 'exits 0 when given no files' {
        Invoke-ScriptFile -Path $script:Script | Should -Be 0
    }

    It 'accepts JSONC (comments and trailing commas)' {
        $f = Join-Path $TestDrive 'ok.jsonc'
        "{`n  // a comment`n  `"a`": 1,`n}" | Set-Content -LiteralPath $f
        Invoke-ScriptFile -Path $script:Script -Arguments @($f) | Should -Be 0
    }

    It 'rejects malformed JSON' {
        $f = Join-Path $TestDrive 'bad.jsonc'
        '{ "a": }' | Set-Content -LiteralPath $f
        Invoke-ScriptFile -Path $script:Script -Arguments @($f) | Should -Not -Be 0
    }
}
