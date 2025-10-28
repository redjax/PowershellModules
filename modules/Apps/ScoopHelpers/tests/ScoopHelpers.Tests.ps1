# Pester tests for ScoopHelpers module

Describe 'ScoopHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $(PSScriptRoot) .. ScoopHelpers.psm1) -Force
         = Get-Module -Name ScoopHelpers
         | Should -Not -Be 
    }
}
