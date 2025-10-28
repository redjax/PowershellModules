# Pester tests for StringHelpers module

Describe 'StringHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $(PSScriptRoot) .. StringHelpers.psm1) -Force
         = Get-Module -Name StringHelpers
         | Should -Not -Be 
    }
}
