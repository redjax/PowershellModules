function Get-PlatformNetwork {
    <#
        .SYNOPSIS
        Return network adapter information.
    #>
    try {
        $NetworkInfo = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | Select-Object -Property `
            Description, `
            MACAddress, `
            IPAddress, `
            DefaultIPGateway, `
            DNSServerSearchOrder
    }
    catch {
        Write-Error "Error getting platform network info. Details: $($_.Exception.Message)"
        exit(1)
    }

    $NetworkInfo
}
