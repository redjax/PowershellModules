function Get-PlatformGPU {
    <#
        .SYNOPSIS
        Return GPU (graphics card) information.
    #>
    try {
        $GPUInfo = Get-WmiObject Win32_VideoController | Select-Object -Property `
            Name, `
            VideoProcessor, `
            DriverVersion, `
            AdapterRAM, `
            CurrentRefreshRate, `
            CurrentHorizontalResolution, `
            CurrentVerticalResolution, `
            CurrentBitsPerPixel, `
            MaxRefreshRate, `
            DeviceID, `
            PNPDeviceID, `
            Status, `
            Description
    }
    catch {
        Write-Error "Error getting platform GPU info. Details: $($_.Exception.Message)"
        exit(1)
    }

    $GPUInfo
}
