# Pester tests for SecurityHelpers module

Describe 'SecurityHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "SecurityHelpers.psm1") -Force
        $Module = Get-Module -Name SecurityHelpers
        $Module -eq $null | Should Be $false
    }
}
