#Requires -Version 7.0
<#
.SYNOPSIS
    Validates AsciiDoc SYNTAX via asciidoctor (pre-commit + CI).

.DESCRIPTION
    Runs `asciidoctor --failure-level=WARN` over the given .adoc files, sending
    rendered output to the platform null device (validation only, no artifacts).
    This checks that the AsciiDoc PARSES; it is not prose linting (that is Vale,
    shipped as an opt-in overlay). Fails fast with a hint if asciidoctor is
    missing. No-ops when handed no files.

.NOTES
    Deliberately NOT the phantom "asciidoctor-lint" gem, which does not exist.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $Path -or $Path.Count -eq 0) {
    Write-Verbose 'No AsciiDoc files to validate.'
    exit 0
}

if (-not (Get-Command asciidoctor -ErrorAction SilentlyContinue)) {
    Write-Error @'
asciidoctor is not installed.
Install it once:  gem install asciidoctor
(Ruby is required — https://docs.asciidoctor.org/asciidoctor/latest/install/)
'@
    exit 1
}

$nullDevice = if ($IsWindows) { 'NUL' } else { '/dev/null' }
$failed = $false

foreach ($file in $Path) {
    if (-not (Test-Path -LiteralPath $file)) { continue }
    Write-Verbose "Validating $file"
    & asciidoctor --failure-level=WARN --out-file $nullDevice -- $file
    if ($LASTEXITCODE -ne 0) { $failed = $true }
}

if ($failed) {
    Write-Error 'asciidoctor found syntax problems (failure-level=WARN).'
    exit 1
}

Write-Verbose 'asciidoctor: syntax OK.'
exit 0
