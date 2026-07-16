#Requires -Version 7.0
<#
.SYNOPSIS
    Validate JSONC (JSON-with-comments) files.

.DESCRIPTION
    Parses each file with System.Text.Json allowing comments and trailing commas,
    so it accepts the JSONC that the strict check-json hook rejects (VS Code
    configs, .config/*.jsonc). No-ops when given no files; fails with the parse
    error for malformed input.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $Path -or $Path.Count -eq 0) { Write-Verbose 'No JSONC files.'; exit 0 }

$opts = [System.Text.Json.JsonDocumentOptions]::new()
$opts.CommentHandling = [System.Text.Json.JsonCommentHandling]::Skip
$opts.AllowTrailingCommas = $true

$failed = $false
foreach ($file in $Path) {
    if (-not (Test-Path -LiteralPath $file)) { continue }
    try {
        [void][System.Text.Json.JsonDocument]::Parse((Get-Content -LiteralPath $file -Raw), $opts)
    }
    catch {
        Write-Error ('Invalid JSONC in {0}: {1}' -f $file, $_.Exception.Message)
        $failed = $true
    }
}

if ($failed) { exit 1 }
Write-Verbose 'JSONC OK.'
exit 0
