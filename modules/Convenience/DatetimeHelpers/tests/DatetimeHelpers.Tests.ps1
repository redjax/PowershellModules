# Pester tests for DatetimeHelpers module

Describe 'DatetimeHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $(PSScriptRoot) .. DatetimeHelpers.psm1) -Force
         = Get-Module -Name DatetimeHelpers
         | Should -Not -Be 
    }
}
