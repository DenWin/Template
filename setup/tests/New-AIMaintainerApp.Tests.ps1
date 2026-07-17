#Requires -Version 7.0
Set-StrictMode -Version Latest

BeforeAll {
    # Dot-source the SUT: defines its functions; the run guard skips execution.
    . (Join-Path $PSScriptRoot '..' 'New-AIMaintainerApp.ps1')
}

Describe 'Get-AppManifest' -Tag 'Fast' {
    BeforeAll {
        $script:M = Get-AppManifest -AppName 'denwin-ai-maintainer' -RedirectUrl 'http://localhost:8712/callback'
    }

    It 'grants exactly Contents RW, Pull requests RW, Metadata RO — nothing else' {
        $p = $script:M.default_permissions
        $p.contents | Should -Be 'write'
        $p.pull_requests | Should -Be 'write'
        $p.metadata | Should -Be 'read'
        $p.Keys.Count | Should -Be 3
    }

    It 'grants no admin, workflow, or secrets permission' {
        $keys = @($script:M.default_permissions.Keys)
        $keys | Should -Not -Contain 'administration'
        $keys | Should -Not -Contain 'workflows'
        $keys | Should -Not -Contain 'secrets'
    }

    It 'keeps the webhook inactive (a maintainer bot needs none)' {
        $script:M.hook_attributes.active | Should -BeFalse
    }

    It 'registers a private app under the given name with the callback redirect' {
        $script:M.public | Should -BeFalse
        $script:M.name | Should -Be 'denwin-ai-maintainer'
        $script:M.redirect_url | Should -Be 'http://localhost:8712/callback'
    }
}

Describe 'Get-ManifestFormHtml' -Tag 'Fast' {
    BeforeAll {
        $manifest = Get-AppManifest -AppName 'my-bot' -RedirectUrl 'http://localhost:8712/callback'
        $script:Html = Get-ManifestFormHtml -Manifest $manifest -Owner 'DenWin'
    }

    It 'posts to the personal-account manifest endpoint by default' {
        $script:Html | Should -Match 'action="https://github\.com/settings/apps/new'
    }

    It 'posts to the organization endpoint when -Organization is set' {
        $manifest = Get-AppManifest -AppName 'my-bot' -RedirectUrl 'http://localhost:8712/callback'
        $orgHtml = Get-ManifestFormHtml -Manifest $manifest -Owner 'my-org' -Organization
        $orgHtml | Should -Match 'action="https://github\.com/organizations/my-org/settings/apps/new'
    }

    It 'embeds the manifest JSON and auto-submits' {
        $script:Html | Should -Match 'my-bot'
        $script:Html | Should -Match '\.submit\(\)'
    }
}

Describe 'Save-AppCredential' -Tag 'Fast' {
    It 'writes the private key next to nothing else and returns its path' {
        $dir = Join-Path $TestDrive 'keys'
        $app = @{ id = 42; slug = 'my-bot'; pem = "-----BEGIN RSA PRIVATE KEY-----`nkey`n-----END RSA PRIVATE KEY-----" }
        $path = Save-AppCredential -App $app -OutputDirectory $dir
        $path | Should -Be (Join-Path $dir 'my-bot.private-key.pem')
        Get-Content $path -Raw | Should -Match 'BEGIN RSA PRIVATE KEY'
    }
}

Describe 'Invoke-AppCreation' -Tag 'Fast' {
    It 'returns non-zero when gh is not installed' {
        Mock Test-GhCli { $false }
        Invoke-AppCreation -AppName 'x' 2>$null | Should -Be 1
    }
}
