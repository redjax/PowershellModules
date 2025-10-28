# Pester tests for PathHelpers module

Describe 'PathHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $(PSScriptRoot) .. PathHelpers.psm1) -Force
         = Get-Module -Name PathHelpers
         | Should -Not -Be 
    }
}
