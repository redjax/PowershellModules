function Get-ParentPath {
    ## Return the parent directory for a given path.
    param(
        [string]$Path
    )

    if (-not ($Path)) {
        Write-Warning "-Path is empty."
        return
    }

    $ParentPath = Split-Path -Path $Path -Parent

    return $ParentPath
}