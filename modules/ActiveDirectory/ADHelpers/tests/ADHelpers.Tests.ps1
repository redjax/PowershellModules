# Pester tests for ADHelpers module

Describe 'ADHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "ADHelpers.psm1") -Force
        $Module = Get-Module -Name ADHelpers
        $Module -eq $null | Should Be $false
    }
}
