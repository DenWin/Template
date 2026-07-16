#Requires -Version 7.0
<#
    Custom PSScriptAnalyzer rule, loaded via CustomRulePath in
    ../PSScriptAnalyzerSettings.psd1. See .config/scripts/README.md.
#>

Set-StrictMode -Version Latest

function Measure-RequireStrictMode {
    <#
    .SYNOPSIS
        Flags a script that never calls Set-StrictMode.
    .DESCRIPTION
        `Set-StrictMode -Version Latest` turns unassigned variables, missing
        properties and malformed calls into errors instead of silent bugs — the
        fail-fast baseline this repo expects. The rule fires once per file when
        no Set-StrictMode invocation is present anywhere in it.
    .PARAMETER ScriptBlockAst
        Script block AST supplied by PSScriptAnalyzer for each block in the file.
    .OUTPUTS
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.Language.ScriptBlockAst]$ScriptBlockAst
    )

    process {
        # Evaluate only the file's root block. Nested blocks (functions, script
        # blocks) inherit strict mode, so checking them would raise a duplicate
        # finding per block.
        if ($null -ne $ScriptBlockAst.Parent) { return }

        # Data files (*.psd1) are declarative manifests, not executable scripts;
        # Set-StrictMode does not apply to them.
        if ($ScriptBlockAst.Extent.File -like '*.psd1') { return }

        $hasStrictMode = $ScriptBlockAst.FindAll({
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.GetCommandName() -eq 'Set-StrictMode'
            }, $true)

        if ($hasStrictMode) { return }

        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
            'Script does not call Set-StrictMode. Add `Set-StrictMode -Version Latest` near the top to fail fast on unassigned variables and typos.',
            $ScriptBlockAst.Extent,
            'Measure-RequireStrictMode',
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
            $ScriptBlockAst.Extent.File
        )
    }
}

Export-ModuleMember -Function Measure-RequireStrictMode
