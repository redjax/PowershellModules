function Get-PlatformBIOS {
    <#
        .SYNOPSIS
        Return BIOS/firmware information.
    #>
    try {
        $BIOSInfo = Get-WmiObject Win32_BIOS | Select-Object -Property `
            Manufacturer, `
            Name, `
            Version, `
            SerialNumber, `
            ReleaseDate, `
            Status, `
            PrimaryBIOS, `
            SMBIOSPresent, `
            SMBIOSBIOSVersion, `
            SMBIOSMajorVersion, `
            SMBIOSMinorVersion, `
            Description, `
            CurrentLanguage
            
            
            
            
            
    }
    catch {
        Write-Error "Error getting platform BIOS info. Details: $($_.Exception.Message)"
        exit(1)
    }

    $BIOSInfo
}
