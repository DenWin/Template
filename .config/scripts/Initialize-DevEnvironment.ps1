#Requires -Version 7.0
<#
.SYNOPSIS
    One-time local setup: pre-commit (isolated via uv) plus the pwsh modules the
    local hooks need.

.DESCRIPTION
    Idempotent — safe to re-run. pre-commit is installed with uv so it stays
    isolated from your default Python.

    Windows note: do NOT run this (or VS Code) elevated / as admin. Under an
    admin token, new temp dirs are owned by BUILTIN\Administrators and Git for
    Windows fails to init in them (`cannot mkdir ...: File exists`), so
    pre-commit can't fetch hooks. A normal, non-elevated shell works fine.

.PARAMETER PythonVersion
    Optional interpreter for uv to run pre-commit under (e.g. '3.12'). Omit to
    let uv choose.

.PARAMETER UpdateHooks
    Also run `pre-commit autoupdate` to pin hook revisions.
#>
[CmdletBinding()]
param(
    [string]$PythonVersion,
    [switch]$UpdateHooks
)

Set-StrictMode -Version Latest

function Test-Command { param([string]$Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

function Test-Elevated {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Invoke-DevModuleInstall {
    param([string]$Name, [string]$MinimumVersion)
    Install-Module -Name $Name -MinimumVersion $MinimumVersion -Scope CurrentUser -Force -Repository PSGallery
}

function Invoke-PreCommitInstall {
    param([string]$PythonVersion, [switch]$UpdateHooks)

    $toolArgs = @('tool', 'install', 'pre-commit')
    if ($PythonVersion) { $toolArgs += @('--python', $PythonVersion) }
    & uv @toolArgs
    if ($LASTEXITCODE -ne 0) { throw 'uv tool install pre-commit failed.' }
    & uv tool update-shell | Out-Null

    $precommit = (Get-Command pre-commit -ErrorAction SilentlyContinue)?.Source
    if (-not $precommit) { $precommit = Join-Path $HOME '.local/bin/pre-commit.exe' }
    if (-not (Test-Path $precommit)) {
        throw "pre-commit not found after install. Open a new shell (PATH was updated) and re-run, or add $HOME\.local\bin to PATH."
    }

    if ($UpdateHooks) {
        & $precommit autoupdate
        if ($LASTEXITCODE -ne 0) { throw 'pre-commit autoupdate failed.' }
    }
    & $precommit install --install-hooks
    if ($LASTEXITCODE -ne 0) { throw 'pre-commit install failed.' }
}

function Invoke-Initialize {
    param([string]$PythonVersion, [switch]$UpdateHooks)

    # Return codes are the contract; keep Write-Error non-terminating even when a
    # caller (e.g. the test lane) runs us under $ErrorActionPreference = 'Stop'.
    $ErrorActionPreference = 'Continue'

    if (-not (Test-Command git)) { Write-Error 'git is not on PATH.'; return 1 }

    if (Test-Elevated) {
        Write-Warning 'This shell is ELEVATED (admin). pre-commit will fail to fetch hooks. Close it and run VS Code / your terminal WITHOUT admin rights.'
    }

    if (-not (Test-Command uv)) {
        Write-Error @'
uv is not installed. It manages pre-commit in isolation.
Install uv, then re-run this script:
  winget install astral-sh.uv
  # or: irm https://astral.sh/uv/install.ps1 | iex
Docs: https://docs.astral.sh/uv/getting-started/installation/
'@
        return 1
    }

    foreach ($m in @(
            @{ Name = 'PSScriptAnalyzer'; Min = '1.21.0' },
            @{ Name = 'Pester'; Min = '5.5.0' })) {
        $have = Get-Module -ListAvailable -Name $m.Name | Where-Object { $_.Version -ge [version]$m.Min }
        if ($have) { Write-Verbose "$($m.Name) present."; continue }
        Write-Verbose "Installing $($m.Name)..."
        Invoke-DevModuleInstall -Name $m.Name -MinimumVersion $m.Min
    }

    # asciidoctor backs the asciidoctor-validate hook; it needs Ruby, which this
    # script does not install. Warn (not fail) — the hook only fires on *.adoc.
    if (-not (Test-Command asciidoctor)) {
        if (Test-Command gem) {
            Write-Verbose 'Installing asciidoctor...'
            & gem install asciidoctor --no-document
            if ($LASTEXITCODE -ne 0) { Write-Warning 'gem install asciidoctor failed; committing *.adoc files will fail until it is installed.' }
        }
        else {
            Write-Warning 'Ruby/gem not found — asciidoctor not installed. Committing *.adoc files will fail until Ruby is installed (winget install RubyInstallerTeam.Ruby.3.4) and `gem install asciidoctor` is run.'
        }
    }

    Invoke-PreCommitInstall -PythonVersion $PythonVersion -UpdateHooks:$UpdateHooks
    Write-Information 'Dev environment ready. Hooks active for commit and push.' -InformationAction Continue
    return 0
}

# Execute only when run directly, not when dot-sourced by a test.
if ($MyInvocation.InvocationName -ne '.') {
    exit (Invoke-Initialize -PythonVersion $PythonVersion -UpdateHooks:$UpdateHooks)
}
