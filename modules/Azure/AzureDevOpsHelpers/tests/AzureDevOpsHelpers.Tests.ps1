# Pester tests for AzureDevOpsHelpers module

Describe 'AzureDevOpsHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "AzureDevOpsHelpers.psm1") -Force
        $Module = Get-Module -Name AzureDevOpsHelpers
        $Module -eq $null | Should Be $false
    }
}
