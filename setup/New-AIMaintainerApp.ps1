#Requires -Version 7.0
<#
.SYNOPSIS
    Create a least-privilege GitHub App for an AI maintainer via GitHub's
    app-manifest flow — one browser confirmation, no manual form-filling.

.DESCRIPTION
    GitHub offers no pure-API way to create an App; the manifest flow is the
    scriptable floor (one click). This script:

      1. serves a tiny local page that posts the App manifest to GitHub
         (permissions: Contents RW, Pull requests RW, Metadata RO — no admin,
         no workflows, webhook off, private app),
      2. opens your browser — you confirm the creation on github.com,
      3. receives the redirect, exchanges the temporary code for the App's
         credentials, and saves the private key locally.

    Afterwards INSTALL the app on this repository only (the printed URL), then
    mint short-lived installation tokens for the agent's shell — see
    setup/AI-Maintainer-Identity.adoc. Verify the result with
    setup/Test-AIMaintainerIdentity.ps1. Create one App per locally-run agent
    (Claude Code, Codex CLI, …); vendor-hosted agents (Copilot coding agent,
    Codex cloud) bring their own App — install and scope theirs instead.

.PARAMETER AppName
    App name (globally unique on GitHub). Defaults to '<owner>-ai-maintainer'.

.PARAMETER Organization
    Register the App under the org that owns the repo instead of your
    personal account. Required when the repo is org-owned and the App should
    live with it.

.PARAMETER Port
    Localhost port for the one-shot callback listener.

.PARAMETER OutputDirectory
    Where the App's private key (*.private-key.pem) is stored. Keep it out of
    any repo; move it to your secret manager afterwards.
#>
[CmdletBinding()]
param(
    [string]$AppName,
    [switch]$Organization,
    [ValidateRange(1024, 65535)]
    [int]$Port = 8712,
    [string]$OutputDirectory = (Join-Path $HOME '.github-apps')
)

Set-StrictMode -Version Latest

function Test-GhCli { [bool](Get-Command gh -ErrorAction SilentlyContinue) }

function Get-AppManifest {
    <# Build the app-manifest payload (pure; no side effects). Exactly the
       least-privilege set from AI-Maintainer-Identity.adoc — extending this
       list is a deliberate security decision, not a convenience tweak. #>
    param(
        [Parameter(Mandatory)][string]$AppName,
        [Parameter(Mandatory)][string]$RedirectUrl
    )
    @{
        name                = $AppName
        url                 = 'https://github.com' # required homepage; cosmetic for a private bot
        public              = $false
        redirect_url        = $RedirectUrl
        hook_attributes     = @{ active = $false; url = 'https://example.com/unused' }
        default_permissions = @{
            contents      = 'write'
            pull_requests = 'write'
            metadata      = 'read'
        }
    }
}

function Get-ManifestFormHtml {
    <# Render the self-submitting form GitHub's manifest flow requires (pure).
       Personal accounts post to /settings/apps/new; org-owned Apps to
       /organizations/<org>/settings/apps/new. #>
    param(
        [Parameter(Mandatory)][hashtable]$Manifest,
        [Parameter(Mandatory)][string]$Owner,
        [switch]$Organization
    )
    $target = $Organization ?
        "https://github.com/organizations/$Owner/settings/apps/new" :
        'https://github.com/settings/apps/new'
    $json = [System.Net.WebUtility]::HtmlEncode(($Manifest | ConvertTo-Json -Depth 5 -Compress))
    @"
<!DOCTYPE html>
<html><body>
  <p>Redirecting to GitHub to create the app&hellip;</p>
  <form id="m" action="$target" method="post">
    <input type="hidden" name="manifest" value="$json">
  </form>
  <script>document.getElementById('m').submit()</script>
</body></html>
"@
}

function Save-AppCredential {
    <# Persist the App's private key; returns the file path. #>
    param(
        [Parameter(Mandatory)][object]$App,
        [Parameter(Mandatory)][string]$OutputDirectory
    )
    New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
    $path = Join-Path $OutputDirectory "$($App.slug).private-key.pem"
    Set-Content -Path $path -Value $App.pem -NoNewline
    Protect-PrivateKeyFile -Path $path
    $path
}

function Protect-PrivateKeyFile {
    <# Restrict file access to the current user only. #>
    param([Parameter(Mandatory)][string]$Path)

    if ($IsWindows) {
        # .NET Core dropped [System.IO.File]::SetAccessControl; seed the
        # descriptor from the file itself and apply it with Set-Acl (PS7-native).
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
        $acl = Get-Acl -Path $Path
        $acl.SetOwner($currentUser)
        $acl.SetAccessRuleProtection($true, $false)
        $rule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $currentUser,
            [System.Security.AccessControl.FileSystemRights]::Read -bor [System.Security.AccessControl.FileSystemRights]::Write,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $acl.SetAccessRule($rule)
        Set-Acl -Path $Path -AclObject $acl
        return
    }

    [System.IO.File]::SetUnixFileMode(
        $Path,
        [System.IO.UnixFileMode]::UserRead -bor [System.IO.UnixFileMode]::UserWrite
    )
}

function Wait-ManifestCode {
    <# Serve the form page, open the browser, and block until GitHub redirects
       back with the temporary code (interactive; Ctrl+C to abort). #>
    param(
        [Parameter(Mandatory)][string]$FormHtml,
        [Parameter(Mandatory)][int]$Port
    )
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Start()
    try {
        Start-Process "http://localhost:$Port/"
        Write-Information "Waiting for the browser round-trip on http://localhost:$Port/ (Ctrl+C to abort)…" -InformationAction Continue
        while ($true) {
            $ctx = $listener.GetContext()
            $code = $ctx.Request.QueryString['code']
            $body = $code ?
                '<html><body>App created — you can close this tab and return to the terminal.</body></html>' :
                $FormHtml
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
            $ctx.Response.ContentType = 'text/html; charset=utf-8'
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
            $ctx.Response.Close()
            if ($code) { return $code }
        }
    }
    finally {
        $listener.Stop()
        $listener.Close()
    }
}

function Invoke-AppCreation {
    param(
        [string]$AppName,
        [switch]$Organization,
        [int]$Port = 8712,
        [string]$OutputDirectory = (Join-Path $HOME '.github-apps')
    )

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
    $owner = ($repo -split '/')[0]
    if (-not $AppName) { $AppName = "$owner-ai-maintainer" }

    $manifest = Get-AppManifest -AppName $AppName -RedirectUrl "http://localhost:$Port/callback"
    $html = Get-ManifestFormHtml -Manifest $manifest -Owner $owner -Organization:$Organization
    $code = Wait-ManifestCode -FormHtml $html -Port $Port
    if (-not $code) {
        Write-Error 'No code received from GitHub — app creation was not confirmed.'
        return 1
    }

    # Exchange the temporary code (valid ~1 h, single use) for the credentials.
    $app = gh api --method POST "app-manifests/$code/conversions" 2>$null | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0 -or -not $app) {
        Write-Error 'Exchanging the manifest code failed — the code may have expired; rerun the script.'
        return 1
    }

    $keyPath = Save-AppCredential -App $app -OutputDirectory $OutputDirectory
    Write-Information @"
App created: $($app.slug) (App ID $($app.id))
Private key: $keyPath  — move it to your secret manager; never commit it.
Next steps:
  1. Install it on THIS repo only: $($app.html_url)/installations/new
  2. Note the Installation ID, then mint a repository-scoped token:
     `$env:GH_TOKEN = pwsh -NoProfile -File setup/New-AIMaintainerToken.ps1 -AppId $($app.id) -InstallationId <id> -Repository $repo -PrivateKeyPath '$keyPath'`
  3. Verify from that shell: pwsh -NoProfile -File setup/Test-AIMaintainerIdentity.ps1
"@ -InformationAction Continue
    return 0
}

# Execute only when run directly, not when dot-sourced by a test.
if ($MyInvocation.InvocationName -ne '.') {
    exit (Invoke-AppCreation -AppName $AppName -Organization:$Organization -Port $Port -OutputDirectory $OutputDirectory)
}
