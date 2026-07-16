#Requires -Version 7.0
Set-StrictMode -Version Latest

BeforeAll {
    # Dot-source the SUT: defines its functions; the run guard skips execution.
    . (Join-Path $PSScriptRoot 'Enable-RepoSecurity.ps1')
}

Describe 'Get-SecuritySetting' -Tag 'Fast' {
    BeforeAll {
        $script:S = Get-SecuritySetting -Repo 'owner/repo' -IncludeWorkflowToken
    }

    It 'enables secret scanning and push protection' {
        $ss = $script:S | Where-Object Name -Match 'secret scanning'
        $ss.Body.security_and_analysis.secret_scanning.status | Should -Be 'enabled'
        $ss.Body.security_and_analysis.secret_scanning_push_protection.status | Should -Be 'enabled'
    }

    It 'flags secret scanning as public-only (GHAS-gated on private)' {
        $ss = $script:S | Where-Object Name -Match 'secret scanning'
        $ss.PublicOnly | Should -BeTrue
    }

    It 'targets the given repo in every path' {
        $script:S.Path | Should -Not -BeNullOrEmpty
        ($script:S.Path | Where-Object { $_ -notmatch 'owner/repo' }) | Should -BeNullOrEmpty
    }

    It 'restricts Actions to an allowlist and requires SHA pinning' {
        $ap = $script:S | Where-Object Name -Match 'Actions policy'
        $ap.Body.allowed_actions | Should -Be 'selected'
        $ap.Body.sha_pinning_required | Should -BeTrue
    }

    It 'allowlists GitHub-owned, verified, and the pinned third-party actions' {
        $al = $script:S | Where-Object Name -Match 'Actions allowlist'
        $al.Body.github_owned_allowed | Should -BeTrue
        $al.Body.verified_allowed | Should -BeTrue
        $al.Body.patterns_allowed | Should -Contain 'gitleaks/gitleaks-action@*'
    }

    It 'orders the Actions policy before its allowlist (selected-actions 409s otherwise)' {
        $names = @($script:S.Name)
        $names.IndexOf(($names -match 'Actions policy')[0]) |
            Should -BeLessThan $names.IndexOf(($names -match 'Actions allowlist')[0])
    }

    It 'sets the workflow token read-only when requested' {
        $wt = $script:S | Where-Object Name -Match 'workflow token'
        $wt.Body.default_workflow_permissions | Should -Be 'read'
    }

    It 'omits the workflow-token change when not requested' {
        $noToken = Get-SecuritySetting -Repo 'owner/repo'
        ($noToken | Where-Object Name -Match 'workflow token') | Should -BeNullOrEmpty
    }
}

Describe 'Invoke-RepoSecurity' -Tag 'Fast' {
    It 'returns non-zero when gh is not installed' {
        Mock Test-GhCli { $false }
        Invoke-RepoSecurity 2>$null | Should -Be 1
    }
}
