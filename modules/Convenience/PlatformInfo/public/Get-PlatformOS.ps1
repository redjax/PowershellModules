function Get-PlatformOS {
    <#
        .SYNOPSIS
        Return operating system information.
    #>
    try {
        $OSInfo = Get-WmiObject Win32_OperatingSystem | Select-Object -Property `
            Caption, `
            Version, `
            BuildNumber, `
            OSArchitecture, `
            SerialNumber, `
            LastBootUpTime, `
            InstallDate, `
            RegisteredUser, `
            SystemDrive, `
            SystemDirectory, `
            WindowsDirectory, `
            TotalVisibleMemorySize, `
            FreePhysicalMemory, `
            SizeStoredInPagingFiles, `
            FreeVirtualMemory, `
            FreeSpaceInPagingFiles
    }
    catch {
        Write-Error "Error getting platform OS info. Details: $($_.Exception.Message)"
        exit(1)
    }

    $OSInfo
}
