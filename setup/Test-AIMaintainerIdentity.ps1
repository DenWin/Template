#Requires -Version 7.0
<#
.SYNOPSIS
    Verify that the credential in the current shell is a least-privilege
    AI-maintainer identity — not the owner's admin account.

.DESCRIPTION
    Run this from the shell an AI agent will use (the agent inherits that
    shell's gh/git credential). It classifies the active token and checks its
    effective permission on this repo, then fails unless ALL hold:

      - the token is a GitHub App installation token (ghs_) or a fine-grained
        PAT (github_pat_) — see setup/AI-Maintainer-Identity.adoc for how to
        create one (New-AIMaintainerApp.ps1 automates the App path), and
      - the credential does NOT have admin on the repo, and
      - the credential has effective write access (`permissions.push=true`) on
        this repository.

    Everything else fails closed: an OAuth user token (gho_, your interactive
    `gh auth login` session), a classic PAT (ghp_, unscoped), or an
    unrecognized format. Exit code 0 = safe to hand this shell to an agent.
    Complete-Setup.ps1 runs this check before removing the setup/ folder.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest

function Test-GhCli { [bool](Get-Command gh -ErrorAction SilentlyContinue) }

function Get-TokenKind {
    <# Classify a GitHub token by its documented prefix (pure; no side effects).
       https://github.blog/engineering/behind-githubs-new-authentication-token-formats/ #>
    param([Parameter(Mandatory)][string]$Token)
    switch -Regex ($Token) {
        '^ghs_' { 'Installation'; break }        # App installation (server-to-server)
        '^github_pat_' { 'FineGrainedPat'; break }
        '^ghp_' { 'ClassicPat'; break }
        '^gho_' { 'OAuthUser'; break }           # interactive `gh auth login`
        '^ghu_' { 'UserToServer'; break }        # App acting AS the signed-in user
        default { 'Unknown' }
    }
}

function Get-IdentityVerdict {
    <# Apply the least-privilege rules to the gathered facts (pure; no side
       effects). Fails closed: only the two identity mechanisms from
       AI-Maintainer-Identity.adoc pass, never with admin, and only with
       effective write permission on this repo. #>
    param(
        [Parameter(Mandatory)][string]$TokenKind,
        [Parameter(Mandatory)][bool]$HasAdmin,
        [Parameter(Mandatory)][bool]$HasWrite,
        [string]$ActorLogin = '',
        [string]$RepositoryOwner = ''
    )
    $findings = [System.Collections.Generic.List[string]]::new()

    if ($HasAdmin) {
        $findings.Add('Credential has ADMIN on this repo — an agent could disable the branch ruleset. Use a write-only identity.')
    }
    if (-not $HasWrite) {
        $findings.Add('Credential lacks write/push permission on this repo — setup cannot proceed with a read-only token.')
    }
    switch ($TokenKind) {
        'Installation' { }
        'FineGrainedPat' {
            if ([string]::IsNullOrWhiteSpace($ActorLogin) -or
                [string]::IsNullOrWhiteSpace($RepositoryOwner)) {
                $findings.Add('Could not verify that the fine-grained PAT belongs to a separate maintainer identity; failing closed.')
            }
            elseif ($ActorLogin.Equals($RepositoryOwner, [System.StringComparison]::OrdinalIgnoreCase)) {
                $findings.Add('Fine-grained PAT belongs to the repository owner, not a separate maintainer identity. Use a GitHub App for a personal repository.')
            }
        }
        'OAuthUser' { $findings.Add('Token is an OAuth user token — the owner''s interactive gh session, not a separate agent identity. Actions would be attributed to your own account.') }
        'UserToServer' { $findings.Add('Token is a user-to-server App token — it acts as the signed-in user, so agent actions are attributed to you.') }
        'ClassicPat' { $findings.Add('Token is a classic PAT — it cannot be scoped per-permission or per-repo. Replace it with a fine-grained PAT or an App installation token.') }
        default { $findings.Add("Token format not recognized ($TokenKind) — cannot verify least privilege; failing closed.") }
    }

    @{ Pass = ($findings.Count -eq 0); Findings = $findings }
}

function Invoke-IdentityCheck {
    # Return codes are the contract; keep Write-Error non-terminating.
    $ErrorActionPreference = 'Continue'

    if (-not (Test-GhCli)) {
        Write-Error 'GitHub CLI (gh) is not installed. https://cli.github.com/'
        return 1
    }
    $repo = gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>$null
    if (-not $repo) {
        Write-Error 'Not a GitHub repository, or gh is not authenticated (`gh auth login`).'
        return 1
    }
    $token = gh auth token 2>$null
    if (-not $token) {
        Write-Error 'No token available in this shell (`gh auth token` returned nothing).'
        return 1
    }

    $tokenKind = Get-TokenKind -Token $token
    $repoOwner = ($repo -split '/', 2)[0]
    $actorLogin = ''
    if ($tokenKind -eq 'FineGrainedPat') {
        $actorLogin = gh api user --jq '.login' 2>$null
    }

    # Effective permissions of THIS credential on THIS repo; missing/erroring
    # fields fail closed.
    $admin = gh api "repos/$repo" --jq '.permissions.admin' 2>$null
    $push = gh api "repos/$repo" --jq '.permissions.push' 2>$null
    $hasAdmin = "$admin" -eq 'true'
    $hasWrite = "$push" -eq 'true'

    $verdict = Get-IdentityVerdict -TokenKind $tokenKind -HasAdmin $hasAdmin -HasWrite $hasWrite `
        -ActorLogin "$actorLogin" -RepositoryOwner $repoOwner
    if (-not $verdict.Pass) {
        $verdict.Findings | ForEach-Object { Write-Error $_ }
        Write-Error "This shell's credential is NOT a least-privilege AI-maintainer identity for $repo. See setup/AI-Maintainer-Identity.adoc."
        return 1
    }
    Write-Information "Credential is a least-privilege AI-maintainer identity for $repo." -InformationAction Continue
    return 0
}

# Execute only when run directly, not when dot-sourced by a test.
if ($MyInvocation.InvocationName -ne '.') {
    exit (Invoke-IdentityCheck)
}
