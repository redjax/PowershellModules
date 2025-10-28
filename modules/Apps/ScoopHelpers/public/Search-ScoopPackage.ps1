function Search-ScoopPackage {
    <#
        .SYNOPSIS
        Search scoop for a package by name

        .DESCRIPTION
        Lists all scoop apps, then searches for your $Package string in the output. If a matching string is found,
        the function tells you it's a valid package name.

        .PARAMETER Package
        The name of the package to search for
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "The name of the package to search for. Default: `$null")]
        [string]$Package = $null
    )

    if ( -not $Package ) {
        Write-Error "A package name is required."
        return
    }

    Write-Output "Searching scoop for package '$($Package)' ..."

    try {
        $PackageExists = ( Test-ScoopPackageExists -PackageName $Package )
    }
    catch {
        Write-Error "Failed to search scoop for package '$($Package)'. Details: $($exc.Message)"
        $PackageExists = $false
    }

    Write-Host "Package '" -NoNewline ; `
        Write-Host "$($Package)" -ForegroundColor Cyan -NoNewline ; `
        Write-Host "' exists in scoop's repos: " -NoNewline ; `
        if ( $PackageExists ) { Write-Host "TRUE" -ForegroundColor Green } else { Write-Host "FALSE" -ForegroundColor Red }

    return
}