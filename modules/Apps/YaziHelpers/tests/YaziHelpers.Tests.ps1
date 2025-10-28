# Pester tests for YaziHelpers module

Describe 'YaziHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "YaziHelpers.psm1") -Force
        $Module = Get-Module -Name YaziHelpers
        $Module -eq $null | Should Be $false
    }
}
