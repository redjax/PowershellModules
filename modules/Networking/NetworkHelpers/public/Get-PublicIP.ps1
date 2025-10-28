function Get-PublicIP {
    <#
            .SYNOPSIS
            Return your public IP address by making an HTTP request to ifconfig.me/ip.
        #>
        Write-Output "Making request to https://ifconfig.me/ip"
        try {
            (Invoke-WebRequest https://ifconfig.me/ip).Content
        } catch {
            Write-Error "Error requesting public IP. Details: $($_.Exception.Message)"
            return $_.Exception
        }
    }