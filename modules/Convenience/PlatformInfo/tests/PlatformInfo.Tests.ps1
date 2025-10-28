# Pester tests for PlatformInfo module

Describe 'PlatformInfo' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "PlatformInfo.psm1") -Force
        $Module = Get-Module -Name PlatformInfo
        $Module -eq $null | Should Be $false
    }
}
