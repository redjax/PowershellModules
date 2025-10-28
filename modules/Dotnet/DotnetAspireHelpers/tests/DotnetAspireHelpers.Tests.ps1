# Pester tests for DotnetAspireHelpers module

Describe 'DotnetAspireHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "DotnetAspireHelpers.psm1") -Force
        $Module = Get-Module -Name DotnetAspireHelpers
        $Module -eq $null | Should Be $false
    }
}
