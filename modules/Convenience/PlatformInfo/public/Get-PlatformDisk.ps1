function Get-PlatformDisk {
    <#
        .SYNOPSIS
        Return disk drive information.
    #>
    try {
        $DiskInfo = Get-WmiObject Win32_DiskDrive | Select-Object -Property `
            Model, `
            InterfaceType, `
            MediaType, `
            Size, `
            Partitions, `
            SerialNumber, `
            DeviceID, `
            Status, `
            Name
    }
    catch {
        Write-Error "Error getting platform disk info. Details: $($_.Exception.Message)"
        exit(1)
    }

    $DiskInfo
}
