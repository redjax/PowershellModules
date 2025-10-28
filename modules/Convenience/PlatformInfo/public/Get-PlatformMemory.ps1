function Get-PlatformMemory {
    <#
        .SYNOPSIS
        Return memory (RAM) information.
    #>
    try {
        $MemoryInfo = Get-WmiObject Win32_PhysicalMemory | Select-Object -Property `
            Capacity, `
            Speed, `
            Manufacturer, `
            PartNumber, `
            SerialNumber, `
            DeviceLocator, `
            FormFactor, `
            MemoryType, `
            ConfiguredClockSpeed, `
            BankLabel
    }
    catch {
        Write-Error "Error getting platform memory info. Details: $($_.Exception.Message)"
        exit(1)
    }

    $MemoryInfo
}
