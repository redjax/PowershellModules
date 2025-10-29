<#
.SYNOPSIS
    Updates the Categories and Modules sections in README.md from manifest.json.

.DESCRIPTION
    This script reads the repository manifest.json file and automatically updates
    the Categories and Modules sections in the README.md file. It uses special
    HTML comment markers to identify where to insert the generated content.
    
    Categories section: Generates a bulleted list of unique categories with links
    Modules section: Generates a table with module names and categories, all linked

.EXAMPLE
    .\Update-ReadmeSections.ps1
    
    Updates the README.md file with current manifest data.

.NOTES
    The script always operates relative to its own location, so it works correctly
    regardless of the current working directory when executed.
    
    The README.md must contain these markers:
    - <!-- BEGIN CATEGORIES --><!-- END CATEGORIES -->
    - <!-- BEGIN MODULES --><!-- END MODULES -->
#>

[CmdletBinding()]
param()

## Get the script's directory and calculate repository root
$ScriptPath = $PSScriptRoot
$RepoRoot = Split-Path -Path $ScriptPath -Parent
$ManifestPath = Join-Path -Path $RepoRoot -ChildPath "manifest.json"
$ReadmePath = Join-Path -Path $RepoRoot -ChildPath "README.md"

Write-Verbose "Script Path: $ScriptPath"
Write-Verbose "Repository Root: $RepoRoot"
Write-Verbose "Manifest Path: $ManifestPath"
Write-Verbose "README Path: $ReadmePath"

## Verify files exist
if (-not (Test-Path -Path $ManifestPath)) {
    Write-Error "Manifest file not found at: $ManifestPath"
    exit 1
}

if (-not (Test-Path -Path $ReadmePath)) {
    Write-Error "README file not found at: $ReadmePath"
    exit 1
}

## Read and parse manifest.json
Write-Host "Reading manifest.json" -ForegroundColor Cyan
try {
    $manifest = Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json
    $modules = $manifest.modules

    Write-Host "Found $($modules.Count) modules" -ForegroundColor Green
}
catch {
    Write-Error "Failed to read or parse manifest.json: $_"
    exit 1
}

## Generate Categories section
Write-Host "`nGenerating Categories section" -ForegroundColor Cyan
$categories = $modules | Select-Object -ExpandProperty category -Unique | Sort-Object

$categoriesMarkdown = @()
$categoriesMarkdown += ""

foreach ($category in $categories) {
    $categoryPath = "modules/$category"
    $categoriesMarkdown += "- [$category](./$categoryPath)"
}

$categoriesMarkdown += ""

$categoriesContent = $categoriesMarkdown -join "`n"
Write-Host "Generated $($categories.Count) category links" -ForegroundColor Green

## Generate Modules section
Write-Host "`nGenerating Modules section" -ForegroundColor Cyan

$modulesMarkdown = @()
$modulesMarkdown += ""
$modulesMarkdown += "| Name | Category |"
$modulesMarkdown += "|------|----------|"

## Sort modules by category, then name
$sortedModules = $modules | Sort-Object -Property category, name

foreach ($module in $sortedModules) {
    $namePath = "./$($module.path)"
    $categoryPath = "./modules/$($module.category)"
    $modulesMarkdown += "| [$($module.name)]($namePath) | [$($module.category)]($categoryPath) |"
}

$modulesMarkdown += ""

$modulesContent = $modulesMarkdown -join "`n"
Write-Host "Generated table with $($modules.Count) modules" -ForegroundColor Green

## Read current README
Write-Host "`nReading README.md" -ForegroundColor Cyan
$readmeContent = Get-Content -Path $ReadmePath -Raw

## Define markers
$categoriesBeginMarker = "<!-- BEGIN CATEGORIES -->"
$categoriesEndMarker = "<!-- END CATEGORIES -->"
$modulesBeginMarker = "<!-- BEGIN MODULES -->"
$modulesEndMarker = "<!-- END MODULES -->"

## Update Categories section
if ($readmeContent -match "(?s)$([regex]::Escape($categoriesBeginMarker)).*?$([regex]::Escape($categoriesEndMarker))") {
    Write-Host "Updating Categories section" -ForegroundColor Cyan

    $newCategoriesSection = "$categoriesBeginMarker$categoriesContent$categoriesEndMarker"
    $readmeContent = $readmeContent -replace "(?s)$([regex]::Escape($categoriesBeginMarker)).*?$([regex]::Escape($categoriesEndMarker))", $newCategoriesSection
}
else {
    Write-Warning "Categories markers not found in README.md. Please add '$categoriesBeginMarker' and '$categoriesEndMarker' markers."
}

## Update Modules section
if ($readmeContent -match "(?s)$([regex]::Escape($modulesBeginMarker)).*?$([regex]::Escape($modulesEndMarker))") {
    Write-Host "Updating Modules section" -ForegroundColor Cyan

    $newModulesSection = "$modulesBeginMarker$modulesContent$modulesEndMarker"
    $readmeContent = $readmeContent -replace "(?s)$([regex]::Escape($modulesBeginMarker)).*?$([regex]::Escape($modulesEndMarker))", $newModulesSection
}
else {
    Write-Warning "Modules markers not found in README.md. Please add '$modulesBeginMarker' and '$modulesEndMarker' markers."
}

## Write updated README
try {
    Set-Content -Path $ReadmePath -Value $readmeContent -NoNewline -Encoding UTF8
    Write-Host "`nREADME.md updated successfully!" -ForegroundColor Green
    Write-Host "Location: $ReadmePath" -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to write README.md: $_"
    exit 1
}

## Summary
Write-Host "`nSummary:" -ForegroundColor Yellow
Write-Host "  Categories: $($categories.Count)" -ForegroundColor White
Write-Host "  Modules: $($modules.Count)" -ForegroundColor White
