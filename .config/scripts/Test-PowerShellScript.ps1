#Requires -Version 7.0
<#
.SYNOPSIS
    Runs PSScriptAnalyzer over the given PowerShell files (pre-commit + CI).

.DESCRIPTION
    Invoked as a pre-commit `repo: local` hook; pre-commit passes staged file
    paths as arguments. The SAME script runs in CI. Fails fast with an install
    hint if PSScriptAnalyzer is not present (the module is NOT managed by
    pre-commit). No-ops cleanly when handed no files.

.NOTES
    Gate severity and rule tuning live in .config/PSScriptAnalyzerSettings.psd1.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $Path -or $Path.Count -eq 0) {
    Write-Verbose 'No PowerShell files to analyse.'
    exit 0
}

if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Error @'
PSScriptAnalyzer is not installed.
Install it once:  Install-Module PSScriptAnalyzer -Scope CurrentUser
Or run:           .config/scripts/Initialize-DevEnvironment.ps1
'@
    exit 1
}

Import-Module PSScriptAnalyzer -ErrorAction Stop

$settingsPath = Join-Path $PSScriptRoot '..' 'PSScriptAnalyzerSettings.psd1' |
    Resolve-Path | Select-Object -ExpandProperty Path

# Custom rules live beside the settings. Pass the module explicitly (absolute) so
# resolution is independent of the caller's working directory; -Settings still
# governs severity and IncludeDefaultRules.
$customRulePath = Join-Path $PSScriptRoot '..' 'PSScriptAnalyzerRules' 'Measure-RequireStrictMode.psm1' |
    Resolve-Path | Select-Object -ExpandProperty Path

$findings = foreach ($file in $Path) {
    if (-not (Test-Path -LiteralPath $file)) { continue }
    Invoke-ScriptAnalyzer -Path $file -Settings $settingsPath -CustomRulePath $customRulePath
}

if ($findings) {
    $findings | Format-Table -AutoSize | Out-String -Width 4096 | Write-Output
    Write-Error "PSScriptAnalyzer reported $($findings.Count) issue(s)."
    exit 1
}

Write-Verbose 'PSScriptAnalyzer: clean.'
exit 0
