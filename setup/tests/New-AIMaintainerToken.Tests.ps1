#Requires -Version 7.0
Set-StrictMode -Version Latest

BeforeAll {
    . (Join-Path $PSScriptRoot '..' 'New-AIMaintainerToken.ps1')
}

Describe 'ConvertTo-Base64Url' -Tag 'Fast' {
    It 'uses URL-safe unpadded base64' {
        ConvertTo-Base64Url -Bytes ([byte[]](251, 255, 239)) |
            Should -Be '-__v'
    }
}

Describe 'Get-GitHubAppJwt' -Tag 'Fast' {
    It 'creates a verifiable RS256 token with a short GitHub App lifetime' {
        $rsa = [System.Security.Cryptography.RSA]::Create(2048)
        try {
            $keyPath = Join-Path $TestDrive 'app-key.pem'
            [System.IO.File]::WriteAllText(
                $keyPath,
                $rsa.ExportRSAPrivateKeyPem(),
                [System.Text.UTF8Encoding]::new($false)
            )
            $now = [DateTimeOffset]::FromUnixTimeSeconds(2000000000)

            $jwt = Get-GitHubAppJwt -AppId 12345 -PrivateKeyPath $keyPath -Now $now

            $parts = $jwt -split '\.'
            $parts.Count | Should -Be 3
            $payload = ConvertFrom-Base64Url -Value $parts[1] |
                ForEach-Object { [System.Text.Encoding]::UTF8.GetString($_) } |
                ConvertFrom-Json
            $payload.iss | Should -Be '12345'
            $payload.iat | Should -Be 1999999940
            $payload.exp | Should -Be 2000000540

            $signature = ConvertFrom-Base64Url -Value $parts[2]
            $rsa.VerifyData(
                [System.Text.Encoding]::UTF8.GetBytes("$($parts[0]).$($parts[1])"),
                $signature,
                [System.Security.Cryptography.HashAlgorithmName]::SHA256,
                [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
            ) | Should -BeTrue
        }
        finally {
            $rsa.Dispose()
        }
    }
}

Describe 'Get-InstallationAccessToken' -Tag 'Fast' {
    It 'requests a one-repository installation token without expanding permissions' {
        Mock Get-GitHubAppJwt { 'signed-jwt' }
        Mock gh {
            $global:LASTEXITCODE = 0
            '{"token":"test-installation-token"}'
        }

        $token = Get-InstallationAccessToken -AppId 123 -InstallationId 456 `
            -Repository 'owner/repo' -PrivateKeyPath 'unused.pem'

        $token | Should -Be 'test-installation-token'
        Should -Invoke gh -Exactly -Times 1 -ParameterFilter {
            $args -contains 'app/installations/456/access_tokens' -and
            $args -contains 'Authorization: Bearer signed-jwt' -and
            $args -contains 'repositories[]=repo'
        }
    }

    It 'fails when GitHub does not return a token' {
        Mock Get-GitHubAppJwt { 'signed-jwt' }
        Mock gh {
            $global:LASTEXITCODE = 1
            ''
        }

        {
            Get-InstallationAccessToken -AppId 123 -InstallationId 456 `
                -Repository 'owner/repo' -PrivateKeyPath 'unused.pem'
        } | Should -Throw
    }
}
