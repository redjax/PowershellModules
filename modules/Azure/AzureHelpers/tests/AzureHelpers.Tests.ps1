# Pester tests for AzureHelpers module

Describe 'AzureHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "AzureHelpers.psm1") -Force
        $Module = Get-Module -Name AzureHelpers
        $Module -eq $null | Should Be $false
    }
}
