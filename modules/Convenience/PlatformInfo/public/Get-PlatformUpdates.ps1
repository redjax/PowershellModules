function Get-PlatformUpdates {
    <#
        .SYNOPSIS
        Return information about installed and pending updates.
    #>
    try {
        $Updates = Get-HotFix | Select-Object -Property `
            Description, `
            HotFixID, `
            InstalledOn, `
            InstalledBy, `
            PSComputerName
    }
    catch {
        Write-Error "Error retrieving updates. Details: $($_.Exception.Message)"
    }

    $Updates
}
