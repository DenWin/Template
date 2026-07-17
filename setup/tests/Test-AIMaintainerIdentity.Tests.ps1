#Requires -Version 7.0
Set-StrictMode -Version Latest

BeforeAll {
    # Dot-source the SUT: defines its functions; the run guard skips execution.
    . (Join-Path $PSScriptRoot '..' 'Test-AIMaintainerIdentity.ps1')
}

Describe 'Get-TokenKind' -Tag 'Fast' {
    It 'classifies <Kind> from its documented prefix' -ForEach @(
        # Fixtures from GitHub's token-format docs, not real credentials.
        @{ Token = 'ghs_16C7e42F292c6912E7710c838347Ae178B4a'; Kind = 'Installation' } # gitleaks:allow
        @{ Token = 'github_pat_11ABC123_abcdef'; Kind = 'FineGrainedPat' } # gitleaks:allow
        @{ Token = 'ghp_16C7e42F292c6912E7710c838347Ae178B4a'; Kind = 'ClassicPat' } # gitleaks:allow
        @{ Token = 'gho_16C7e42F292c6912E7710c838347Ae178B4a'; Kind = 'OAuthUser' } # gitleaks:allow
        @{ Token = 'ghu_16C7e42F292c6912E7710c838347Ae178B4a'; Kind = 'UserToServer' } # gitleaks:allow
        @{ Token = 'something-else-entirely'; Kind = 'Unknown' }
    ) {
        Get-TokenKind -Token $Token | Should -Be $Kind
    }
}

Describe 'Get-IdentityVerdict' -Tag 'Fast' {
    It 'passes an installation token without admin' {
        (Get-IdentityVerdict -TokenKind 'Installation' -HasAdmin $false -HasWrite $true).Pass | Should -BeTrue
    }

    It 'passes a fine-grained PAT without admin' {
        (Get-IdentityVerdict -TokenKind 'FineGrainedPat' -HasAdmin $false -HasWrite $true).Pass | Should -BeTrue
    }

    It 'fails any credential that has admin on the repo, naming the containment risk' {
        $v = Get-IdentityVerdict -TokenKind 'Installation' -HasAdmin $true -HasWrite $true
        $v.Pass | Should -BeFalse
        $v.Findings -join ' ' | Should -Match 'admin'
    }

    It 'fails an OAuth user token (the owner''s interactive gh session)' {
        $v = Get-IdentityVerdict -TokenKind 'OAuthUser' -HasAdmin $false -HasWrite $true
        $v.Pass | Should -BeFalse
        $v.Findings -join ' ' | Should -Match 'session|interactive|own account'
    }

    It 'fails a classic PAT (cannot be scoped per-permission)' {
        (Get-IdentityVerdict -TokenKind 'ClassicPat' -HasAdmin $false -HasWrite $true).Pass | Should -BeFalse
    }

    It 'fails closed on an unrecognized token format' {
        (Get-IdentityVerdict -TokenKind 'Unknown' -HasAdmin $false -HasWrite $true).Pass | Should -BeFalse
    }

    It 'fails when the credential cannot push to the repository' {
        $v = Get-IdentityVerdict -TokenKind 'Installation' -HasAdmin $false -HasWrite $false
        $v.Pass | Should -BeFalse
        $v.Findings -join ' ' | Should -Match 'write|push'
    }
}

Describe 'Invoke-IdentityCheck' -Tag 'Fast' {
    It 'returns non-zero when gh is not installed' {
        Mock Test-GhCli { $false }
        Invoke-IdentityCheck 2>$null | Should -Be 1
    }

    It 'returns 0 for a least-privilege bot credential' {
        Mock Test-GhCli { $true }
        Mock gh {
            if ($args -contains 'view') { return 'owner/repo' }
            if ($args -contains 'token') { return 'ghs_16C7e42F292c6912E7710c838347Ae178B4a' } # gitleaks:allow
            if (($args -join ' ') -match 'permissions\.admin') { $global:LASTEXITCODE = 0; return 'false' }
            if (($args -join ' ') -match 'permissions\.push') { $global:LASTEXITCODE = 0; return 'true' }
            $global:LASTEXITCODE = 0
        }
        Invoke-IdentityCheck | Should -Be 0
    }

    It 'returns non-zero when the credential is the owner''s interactive session' {
        Mock Test-GhCli { $true }
        Mock gh {
            if ($args -contains 'view') { return 'owner/repo' }
            if ($args -contains 'token') { return 'gho_16C7e42F292c6912E7710c838347Ae178B4a' } # gitleaks:allow
            if (($args -join ' ') -match 'permissions\.admin') { $global:LASTEXITCODE = 0; return 'true' }
            if (($args -join ' ') -match 'permissions\.push') { $global:LASTEXITCODE = 0; return 'true' }
            $global:LASTEXITCODE = 0
        }
        Invoke-IdentityCheck 2>$null | Should -Be 1
    }

    It 'returns non-zero when token kind is allowed but push/write is missing' {
        Mock Test-GhCli { $true }
        Mock gh {
            if ($args -contains 'view') { return 'owner/repo' }
            if ($args -contains 'token') { return 'github_pat_11ABC123_abcdef' } # gitleaks:allow
            if (($args -join ' ') -match 'permissions\.admin') { $global:LASTEXITCODE = 0; return 'false' }
            if (($args -join ' ') -match 'permissions\.push') { $global:LASTEXITCODE = 0; return 'false' }
            $global:LASTEXITCODE = 0
        }
        Invoke-IdentityCheck 2>$null | Should -Be 1
    }
}
