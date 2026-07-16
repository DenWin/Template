#Requires -Version 7.0
<#
.SYNOPSIS
    Runs a Pester test lane (pre-commit / pre-push / CI).

.DESCRIPTION
    Feedback lanes are execution CADENCES, not test types: a lane is assigned by
    measured cost/risk via a Pester TAG, not by a unit/integration label. This
    script runs every *.Tests.ps1 tagged with the requested lane.

        Fast      -> pre-commit  (fast feedback every commit)
        Standard  -> pre-push    (change-validation before sharing)
        Thorough  -> CI / manual (system-validation before a risky transition)

    The SAME script runs locally and in CI. Fails fast with a hint if Pester is
    missing. No-ops cleanly (exit 0) when the repo has no tests yet — "not
    present" is a valid result, not a failure.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Fast', 'Standard', 'Thorough')]
    [string]$Lane
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..' '..') | Select-Object -ExpandProperty Path

$testFiles = Get-ChildItem -Path $repoRoot -Recurse -File -Filter '*.Tests.ps1' -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '[\\/](\.scratch|\.temp|\.history)[\\/]' }

if (-not $testFiles) {
    Write-Verbose "No *.Tests.ps1 found — nothing to run for the $Lane lane."
    exit 0
}

if (-not (Get-Module -ListAvailable -Name Pester |
            Where-Object { $_.Version -ge [version]'5.0.0' })) {
    Write-Error @'
Pester 5+ is not installed.
Install it once:  Install-Module Pester -MinimumVersion 5.0 -Scope CurrentUser -Force
Or run:           .config/scripts/Initialize-DevEnvironment.ps1
'@
    exit 1
}

Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop

$config = New-PesterConfiguration
$config.Run.Path = $testFiles.FullName  # the filtered set (excludes .temp/.history/.scratch)
$config.Filter.Tag = $Lane          # a test opts into a lane via -Tag
$config.Run.Exit = $false
$config.Run.PassThru = $true        # required, else $result is $null below
$config.Output.Verbosity = 'Detailed'

$result = Invoke-Pester -Configuration $config

if ($result.FailedCount -gt 0) {
    Write-Error "$Lane lane: $($result.FailedCount) test(s) failed."
    exit 1
}

Write-Verbose "$Lane lane: $($result.PassedCount) passed."
exit 0
