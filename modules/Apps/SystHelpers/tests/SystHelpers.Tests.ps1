# Pester tests for SystHelpers module

Describe 'SystHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "SystHelpers.psm1") -Force
        $Module = Get-Module -Name SystHelpers
        $Module -eq $null | Should Be $false
    }
}
