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

.EXAMPLE
    .\tools\New-ModuleTemplate.ps1 -Name MyNewModule
#>

param (
    [Parameter(Mandatory = $true, HelpMessage = "The name of the new module.")]
    [string]$Name
)

# Ensure we're in the repository root
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ModulesPath = Join-Path $RepoRoot "modules"
$ModulePath = Join-Path $ModulesPath $Name

if ( -Not ( Test-Path -Path $ModulesPath ) ) {
    Write-Warning "Modules path '$($ModulesPath)' does not exist. Creating path."
    try {
        New-Item -Path "$($ModulesPath)" -ItemType "directory"
    }
    catch {
        Write-Error "Error creating path '$($ModulesPath)'. Details: $($_.Exception.Message)"
        exit 1
    }
}

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

# Check if the module already exists
if (Test-Path $ModulePath) {
    Write-Error "Module '$Name' already exists in the monorepo."
    exit 1
}

Write-Output "Creating module: $Name in $ModulesPath..."
try {
    Invoke-PSMDTemplate -TemplateName "Module" -Name $Name -OutPath $ModulesPath
}
catch {
    Write-Error "Error creating new module from template. Details: $($_.Exception.Message)"
    exit 1
}

# Ensure required directories exist
$Directories = @("public", "private", "tests")
foreach ($Dir in $Directories) {
    New-Item -Path (Join-Path $ModulePath $Dir) -ItemType Directory -Force | Out-Null
}

# Create a README.md
$ReadmePath = Join-Path $ModulePath "README.md"
if (-not (Test-Path $ReadmePath)) {
    @"
# $Name

This module is part of the PowerShell monorepo.

## Installation

\`\`\`powershell
Import-Module (Join-Path `$(PSScriptRoot) $Name.psm1`)
\`\`\`

## Description

TODO: Describe the module.
"@ | Set-Content -Path $ReadmePath -Encoding utf8
}

# Create an empty Pester test file
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

Write-Output "Module '$Name' has been initialized successfully."
