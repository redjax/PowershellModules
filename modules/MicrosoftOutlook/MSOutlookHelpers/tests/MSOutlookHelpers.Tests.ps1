# Pester tests for MSOutlookHelpers module

Describe 'MSOutlookHelpers' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "MSOutlookHelpers.psm1") -Force
        $Module = Get-Module -Name MSOutlookHelpers
        $Module -eq $null | Should Be $false
    }
}
