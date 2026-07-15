<#
    PSScriptAnalyzer settings — referenced by .config/scripts/Test-PowerShellScript.ps1.

    Gate: Warning + Error block a commit. Tune noise by adding rule names to
    ExcludeRules rather than dropping a whole severity.
#>
@{
    # Severities that constitute a failure.
    Severity            = @('Error', 'Warning')

    # Start from the full built-in rule set.
    IncludeDefaultRules = $true

    # Suppress specific rules that prove too noisy for this repo.
    ExcludeRules        = @(
        # Wants a UTF-8 BOM; conflicts with .editorconfig (charset = utf-8, no BOM).
        'PSUseBOMForUnicodeEncodedFile'
    )
}
