# Pester tests for WeatherMod module

Describe 'WeatherMod' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path $PSScriptRoot ".." "WeatherMod.psm1") -Force
        $Module = Get-Module -Name WeatherMod
        $Module -eq $null | Should Be $false
    }
}
