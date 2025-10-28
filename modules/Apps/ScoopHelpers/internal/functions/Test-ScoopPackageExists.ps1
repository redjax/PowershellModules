function Test-ScoopPackageExists() {
    <#
    .SYNOPSIS
    Check if a Scoop package exists.

    .PARAMETER PackageName
    The name of the package to check.

    .EXAMPLE
    Test-ScoopPackageExists -PackageName "starship"
    #>
    Param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    if ( -Not $PackageName ) {
        Write-Error "Cannot test if Scoop package exists, package name is `$null/empty."
        exit 1
    }

    if ( scoop list | Select-String -Pattern "$PackageName" ) {
        Write-Debug "Scoop package '$PackageName' is installed."
        return $true
    }
    else {
        Write-Debug "Scoop package '$PackageName' is not installed."
        return $false
    }
}