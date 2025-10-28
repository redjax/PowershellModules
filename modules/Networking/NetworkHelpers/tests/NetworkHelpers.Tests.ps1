# Pester tests for NetworkHelpers module

Describe 'NetworkHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $(PSScriptRoot) .. NetworkHelpers.psm1) -Force
         = Get-Module -Name NetworkHelpers
         | Should -Not -Be 
    }
}
