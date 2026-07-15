#Requires -Version 7.0
# Shared helpers for the .config/scripts Pester tests. Dot-sourced from each
# *.Tests.ps1 BeforeAll; not a test file itself.

function Invoke-ScriptFile {
    <#
    .SYNOPSIS
        Run a pwsh script file, discard its output, and return its exit code.
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [string[]]$Arguments = @()
    )
    & pwsh -NoProfile -File $Path @Arguments *> $null
    $LASTEXITCODE
}
