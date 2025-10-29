<#
.SYNOPSIS
    Updates the repository manifest JSON file with all PowerShell modules.

.DESCRIPTION
    This script scans the modules/ directory recursively to find all PowerShell modules
    (directories containing .psd1 and/or .psm1 files) and generates a manifest.json file
    at the repository root with information about each module including its name, category,
    and path.

.EXAMPLE
    .\Update-RepoManifest.ps1
    
    Scans the modules directory and updates manifest.json at the repository root.

.NOTES
    The script always operates relative to its own location, so it works correctly
    regardless of the current working directory when executed.
#>

[CmdletBinding()]
param()

# Get the script's directory and calculate repository root
$ScriptPath = $PSScriptRoot
$RepoRoot = Split-Path -Path $ScriptPath -Parent
$ModulesPath = Join-Path -Path $RepoRoot -ChildPath "modules"
$ManifestPath = Join-Path -Path $RepoRoot -ChildPath "manifest.json"

Write-Verbose "Script Path: $ScriptPath"
Write-Verbose "Repository Root: $RepoRoot"
Write-Verbose "Modules Path: $ModulesPath"
Write-Verbose "Manifest Path: $ManifestPath"

# Verify modules directory exists
if (-not (Test-Path -Path $ModulesPath -PathType Container)) {
    Write-Error "Modules directory not found at: $ModulesPath"
    exit 1
}

# Find all PowerShell modules
Write-Host "Scanning for PowerShell modules in: $ModulesPath" -ForegroundColor Cyan

$modules = @()

# Get all category directories (immediate subdirectories under modules/)
$categoryDirs = Get-ChildItem -Path $ModulesPath -Directory

foreach ($categoryDir in $categoryDirs) {
    $category = $categoryDir.Name
    Write-Verbose "Scanning category: $category"
    
    # Get all subdirectories in this category
    $moduleDirs = Get-ChildItem -Path $categoryDir.FullName -Directory
    
    foreach ($moduleDir in $moduleDirs) {
        # Check if directory contains .psd1 or .psm1 files
        $hasPsd1 = Test-Path -Path (Join-Path -Path $moduleDir.FullName -ChildPath "*.psd1")
        $hasPsm1 = Test-Path -Path (Join-Path -Path $moduleDir.FullName -ChildPath "*.psm1")
        
        if ($hasPsd1 -or $hasPsm1) {
            # Calculate relative path from repo root
            $relativePath = $moduleDir.FullName.Replace($RepoRoot, "").TrimStart("\", "/").Replace("\", "/")
            
            $moduleInfo = [PSCustomObject]@{
                name     = $moduleDir.Name
                category = $category
                path     = $relativePath
            }
            
            $modules += $moduleInfo
            Write-Host "  Found module: $($moduleDir.Name) [$category]" -ForegroundColor Green
        }
    }
}

# Sort modules by category and then by name
$modules = $modules | Sort-Object -Property category, name

# Create the manifest structure
$manifest = [PSCustomObject]@{
    modules = $modules
}

# Convert to JSON with proper formatting
$jsonContent = $manifest | ConvertTo-Json -Depth 10

# Write to manifest file
try {
    Set-Content -Path $ManifestPath -Value $jsonContent -Encoding UTF8
    Write-Host "`nManifest updated successfully!" -ForegroundColor Green
    Write-Host "Location: $ManifestPath" -ForegroundColor Cyan
    Write-Host "Total modules found: $($modules.Count)" -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to write manifest file: $_"
    exit 1
}

# Display summary by category
Write-Host "`nModules by category:" -ForegroundColor Yellow
$modules | Group-Object -Property category | ForEach-Object {
    Write-Host "  $($_.Name): $($_.Count)" -ForegroundColor White
}
