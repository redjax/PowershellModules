function Get-PlatformMotherboard {
    <#
        .SYNOPSIS
        Return motherboard/system board information.
    #>
    try {
        $MotherboardInfo = Get-WmiObject Win32_BaseBoard | Select-Object -Property `
            Manufacturer, `
            Product, `
            SerialNumber, `
            Version, `
            Status, `
            Name, `
            Tag, `
            Description
    }
    catch {
        Write-Error "Error getting platform motherboard info. Details: $($_.Exception.Message)"
        exit(1)
    }

    $MotherboardInfo
}
