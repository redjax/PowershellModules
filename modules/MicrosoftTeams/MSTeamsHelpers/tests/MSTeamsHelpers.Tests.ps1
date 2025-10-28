# Pester tests for MSTeamsHelpers module

Describe 'MSTeamsHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "MSTeamsHelpers.psm1") -Force
        $Module = Get-Module -Name MSTeamsHelpers
        $Module -eq $null | Should Be $false
    }
}
