# Pester tests for UnixAliases module

Describe 'UnixAliases' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $(PSScriptRoot) .. UnixAliases.psm1) -Force
         = Get-Module -Name UnixAliases
         | Should -Not -Be 
    }
}
