function Get-PlatformCPU {
    <#
        .SYNOPSIS
        Return CPU information
    #>
    try {
        $CpuInfo = Get-WmiObject Win32_Processor | Select-Object -Property `
            Name, `
            NumberOfCores, `
            NumberOfLogicalProcessors, `
            MaxClockSpeed, `
            CurrentClockSpeed, `
            L1CacheSize, `
            L2CacheSize, `
            L3CacheSize
    }
    catch {
        Write-Error "Error getting platform CPU info. Details: $($_.Exception.Message)"
        exit(1)
    }

    $CpuInfo
}