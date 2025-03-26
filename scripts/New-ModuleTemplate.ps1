<#
    .SYNOPSIS
        Creates a new PowerShell module in the monorepo using Invoke-PSMDTemplate.
        
    .DESCRIPTION
        This script automates the process of setting up a new module by:
        - Creating the module in ./modules/
        - Initializing it with Invoke-PSMDTemplate
        - Setting up a basic folder structure (public, private, tests)
        - Adding a README and test scaffolding

    .PARAMETER Name
        The name of the new module.

    .PARAMETER Category
        Category (subdirectory) for new modules, i.e. '.\modules\`$Category. Path will be created if it does not exist.

    .PARAMETER Description
        Short description for the module.

    .EXAMPLE
        .\tools\New-ModuleTemplate.ps1 -Name MyNewModule -Category "Example" -Description "A new module in the Example\ directory."
#>
param (
    [CmdletBinding()]
    [Parameter(Mandatory = $true, HelpMessage = "The name of the new module.")]
    [string]$Name,
    [Parameter(Mandatory = $true, HelpMessage = "Category (subdirectory) for new modules, i.e. '.\modules\`$Category. Path will be created if it does not exist.")]
    [string]$Category,
    [Parameter(Mandatory = $true, HelpMessage = "Short description for the module.")]
    $Description
)

## Set to path where script was called from (repository root)
$RepoRoot = Split-Path -Parent $PSScriptRoot
## Set path to modules directory
$ModulesPath = Join-Path -Path $RepoRoot -ChildPath "modules"
## Set path to category directory (modules\$Category)
$ModuleCategoryPath = Join-Path -Path $ModulesPath -ChildPath "$Category"
## Set full path to new module
$ModulePath = Join-Path -Path $ModuleCategoryPath -ChildPath $Name

if ( -Not ( Test-Path -Path $ModuleCategoryPath ) ) {
    Write-Warning "Modules path '$($ModuleCategoryPath)' does not exist. Creating path."
    try {
        New-Item -Path "$($ModuleCategoryPath)" -ItemType "directory" -Force
    }
    catch {
        Write-Error "Error creating path '$($ModuleCategoryPath)'. Details: $($_.Exception.Message)"
        exit 1
    }
}

## Ensure PSModuleDevelopment module is installed
If ( -Not (Get-Command Invoke-PSMDTemplate -ErrorAction SilentlyContinue) ) {
    Write-Warning "This script requires the Invoke-PSMDTemplate module. Attempting to install."
    try {
        Install-Module PSModuleDevelopment -Scope CurrentUser -Force
    }
    catch {
        Write-Error "Failed to install required module: PSModuleDevelopment. Details: $($_.Exception.Message)"
        exit 1
    }
}

## Check if the module already exists
if (Test-Path $ModulePath) {
    Write-Error "Module '$Name' already exists at path $ModulePath."
    exit 2
}

Write-Output "Creating module: '$Name' in path: $ModuleCategoryPath..."
try {
    Invoke-PSMDTemplate `
        -TemplateName "Module" `
        -Name $Name `
        -OutPath $ModuleCategoryPath `
        -Parameters @{description = "$Description" }
}
catch {
    Write-Error "Error creating new module from template. Details: $($_.Exception.Message)"
    exit 1
}

## Ensure required directories exist
$Directories = @("public", "private", "tests")
foreach ($Dir in $Directories) {
    New-Item -Path (Join-Path $ModulePath $Dir) -ItemType Directory -Force | Out-Null
}

## Create a README.md
$ReadmePath = Join-Path $ModulePath "README.md"
if (-not (Test-Path $ReadmePath)) {
    @"
# $Name

This module is part of the PowerShell monorepo.

## Installation

` ``` `powershell
Import-Module (Join-Path `$(PSScriptRoot) $Name.psm1`)
```

## Description

$Description
"@ | Set-Content -Path $ReadmePath -Encoding utf8
}

## Create an empty Pester test file
$TestFile = Join-Path -Path (Join-Path -Path $ModulePath -ChildPath "tests") -ChildPath "$Name.Tests.ps1"

if (-not (Test-Path $TestFile)) {
    @"
# Pester tests for $Name module

Describe '$Name' {
    It 'Should import the module without errors' {
        Import-Module (Join-Path `$PSScriptRoot ".." "$Name.psm1") -Force
        `$Module = Get-Module -Name $Name
        `$Module -eq `$null | Should Be `$false
    }
}
"@ | Set-Content -Path $TestFile -Encoding utf8
}

$AppendModuleFunctionExportString = @"


## Export each function
foreach (`$function in (Get-ChildItem "`$ModuleRoot/public" -Recurse -File -Filter "*.ps1")) {
	. Import-ModuleFile -Path `$function.FullName
	`$functionName = `$function.BaseName
	Export-ModuleMember -Function `$functionName
}
"@

$AppendModuleFunctionExportString | Out-File -FilePath $ModulePath\$Name.psm1 -Append -Encoding utf8

Write-Output "`nModule '$Name' has been initialized successfully."
