#Requires -Version 7.0
<#
.SYNOPSIS
    Mint a repository-scoped GitHub App installation token for an AI agent.

.DESCRIPTION
    Signs a short-lived RS256 JSON Web Token with the App private key, then
    exchanges it for an installation token scoped to one repository. The
    installation must already grant that repository and the App permissions
    established by New-AIMaintainerApp.ps1.

    The token is written to stdout only. Capture it into GH_TOKEN in the
    dedicated agent shell; never write it to disk or pass it as a command-line
    argument.
#>
[CmdletBinding()]
param(
    [long]$AppId,
    [long]$InstallationId,
    [string]$Repository,
    [string]$PrivateKeyPath
)

Set-StrictMode -Version Latest

function ConvertTo-Base64Url {
    param([Parameter(Mandatory)][byte[]]$Bytes)

    [Convert]::ToBase64String($Bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

function ConvertFrom-Base64Url {
    param([Parameter(Mandatory)][string]$Value)

    $base64 = $Value.Replace('-', '+').Replace('_', '/')
    switch ($base64.Length % 4) {
        2 { $base64 += '==' }
        3 { $base64 += '=' }
    }
    , [Convert]::FromBase64String($base64)
}

function Get-GitHubAppJwt {
    param(
        [Parameter(Mandatory)][long]$AppId,
        [Parameter(Mandatory)][string]$PrivateKeyPath,
        [DateTimeOffset]$Now = [DateTimeOffset]::UtcNow
    )

    if (-not (Test-Path -LiteralPath $PrivateKeyPath -PathType Leaf)) {
        throw "GitHub App private key not found: $PrivateKeyPath"
    }

    $header = '{"alg":"RS256","typ":"JWT"}'
    $payload = [ordered]@{
        iat = $Now.AddSeconds(-60).ToUnixTimeSeconds()
        exp = $Now.AddMinutes(9).ToUnixTimeSeconds()
        iss = "$AppId"
    } | ConvertTo-Json -Compress

    $headerPart = ConvertTo-Base64Url -Bytes ([System.Text.Encoding]::UTF8.GetBytes($header))
    $payloadPart = ConvertTo-Base64Url -Bytes ([System.Text.Encoding]::UTF8.GetBytes($payload))
    $unsigned = "$headerPart.$payloadPart"

    $rsa = [System.Security.Cryptography.RSA]::Create()
    try {
        $rsa.ImportFromPem([System.IO.File]::ReadAllText($PrivateKeyPath))
        $signature = $rsa.SignData(
            [System.Text.Encoding]::UTF8.GetBytes($unsigned),
            [System.Security.Cryptography.HashAlgorithmName]::SHA256,
            [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
        )
    }
    finally {
        $rsa.Dispose()
    }

    "$unsigned.$(ConvertTo-Base64Url -Bytes $signature)"
}

function Get-InstallationAccessToken {
    param(
        [Parameter(Mandatory)][long]$AppId,
        [Parameter(Mandatory)][long]$InstallationId,
        [Parameter(Mandatory)][ValidatePattern('^[^/]+/[^/]+$')][string]$Repository,
        [Parameter(Mandatory)][string]$PrivateKeyPath
    )

    $jwt = Get-GitHubAppJwt -AppId $AppId -PrivateKeyPath $PrivateKeyPath
    $installationResponse = gh api `
        -H 'Accept: application/vnd.github+json' `
        -H "Authorization: Bearer $jwt" `
        -H 'X-GitHub-Api-Version: 2022-11-28' `
        "repos/$Repository/installation" 2>$null

    if ($LASTEXITCODE -ne 0 -or -not $installationResponse) {
        throw "GitHub App installation not found for '$Repository'. Check the App ID, private key, and repository installation."
    }

    $repositoryInstallationId = ($installationResponse | ConvertFrom-Json).id
    if (-not $repositoryInstallationId -or
        [long]$repositoryInstallationId -ne $InstallationId) {
        throw "Installation ID '$InstallationId' does not belong to repository '$Repository'."
    }

    $repositoryName = ($Repository -split '/', 2)[1]
    $response = gh api --method POST `
        -H 'Accept: application/vnd.github+json' `
        -H "Authorization: Bearer $jwt" `
        -H 'X-GitHub-Api-Version: 2022-11-28' `
        "app/installations/$InstallationId/access_tokens" `
        -f "repositories[]=$repositoryName" 2>$null

    if ($LASTEXITCODE -ne 0 -or -not $response) {
        throw 'GitHub did not create an installation access token. Check the App ID, installation ID, private key, and repository installation.'
    }

    $token = ($response | ConvertFrom-Json).token
    if (-not $token) {
        throw 'GitHub returned an installation-token response without a token.'
    }
    $token
}

function Invoke-AIMaintainerTokenCreation {
    param(
        [long]$AppId,
        [long]$InstallationId,
        [string]$Repository,
        [string]$PrivateKeyPath
    )

    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        throw 'GitHub CLI (gh) is not installed. https://cli.github.com/'
    }
    if ($AppId -le 0 -or $InstallationId -le 0 -or
        [string]::IsNullOrWhiteSpace($Repository) -or
        [string]::IsNullOrWhiteSpace($PrivateKeyPath)) {
        throw 'AppId, InstallationId, Repository (owner/name), and PrivateKeyPath are required.'
    }

    Get-InstallationAccessToken -AppId $AppId -InstallationId $InstallationId `
        -Repository $Repository -PrivateKeyPath $PrivateKeyPath
}

if ($MyInvocation.InvocationName -ne '.') {
    try {
        Invoke-AIMaintainerTokenCreation -AppId $AppId -InstallationId $InstallationId `
            -Repository $Repository -PrivateKeyPath $PrivateKeyPath
        exit 0
    }
    catch {
        Write-Error $_
        exit 1
    }
}
