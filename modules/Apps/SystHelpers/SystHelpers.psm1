$script:ModuleRoot = $PSScriptRoot

#region Load internal/private functions
$internalPath = Join-Path -Path $ModuleRoot -ChildPath "internal"
if (Test-Path -LiteralPath $internalPath) {
    $internalFunctionsPath = Join-Path -Path $internalPath -ChildPath "functions"
    if (Test-Path -LiteralPath $internalFunctionsPath) {
        foreach ($file in [System.IO.Directory]::GetFiles($internalFunctionsPath, "*.ps1", [System.IO.SearchOption]::AllDirectories)) {
            . $file
        }
    }
    
    # Load preimport.ps1 if it exists
    $preimportPath = Join-Path -Path $internalPath -ChildPath "scripts\preimport.ps1"
    if (Test-Path -LiteralPath $preimportPath) {
        . $preimportPath
    }
}
#endregion Load internal/private functions

#region Load functions directory (if exists)
$functionsPath = Join-Path -Path $ModuleRoot -ChildPath "functions"
if (Test-Path -LiteralPath $functionsPath) {
    foreach ($file in [System.IO.Directory]::GetFiles($functionsPath, "*.ps1", [System.IO.SearchOption]::AllDirectories)) {
        . $file
    }
}
#endregion Load functions directory

#region Load and export public functions
$publicPath = Join-Path -Path $ModuleRoot -ChildPath "public"
$exportedFunctions = @()

if (Test-Path -LiteralPath $publicPath) {
    foreach ($file in [System.IO.Directory]::GetFiles($publicPath, "*.ps1", [System.IO.SearchOption]::AllDirectories)) {
        . $file
        # Use filename as function name (standard PowerShell convention)
        $exportedFunctions += [System.IO.Path]::GetFileNameWithoutExtension($file)
    }
}

# Export all collected functions
if ($exportedFunctions.Count -gt 0) {
    Export-ModuleMember -Function $exportedFunctions
}
#endregion Load and export public functions

#region Load postimport.ps1 if it exists
$internalPath = Join-Path -Path $ModuleRoot -ChildPath "internal"
if (Test-Path -LiteralPath $internalPath) {
    $postimportPath = Join-Path -Path $internalPath -ChildPath "scripts\postimport.ps1"
    if (Test-Path -LiteralPath $postimportPath) {
        . $postimportPath
    }
}
#endregion Load postimport.ps1
