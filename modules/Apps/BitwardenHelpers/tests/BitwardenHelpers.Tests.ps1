# Pester tests for BitwardenHelpers module

Describe 'BitwardenHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "BitwardenHelpers.psm1") -Force
        $Module = Get-Module -Name BitwardenHelpers
        $Module -eq $null | Should Be $false
    }
}
