function Test-PortInUse {
    <#
        .SYNOPSIS
        Tests if a service is running on a specified port. Like 'lsof' command for Unix.

        .DESCRIPTION
        This function checks if a service is running on a specified port by querying the TCP connections on the local machine. If a port is in use, a table will be displayed with the port and service name.

        .PARAMETER Port
        The port number to test.

        .EXAMPLE
        Test-PortInUse -Port 80
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "The port number to test.")]
        [int]$Port
    )

    if ( -Not $Port ) {
        Write-Error "The port number cannot be null or empty."
        return
    }

    Write-Output "Testing if a service is running on port $Port ..."
    try {
        Get-NetTCPConnection | Where-Object { $_.LocalPort -eq $Port } | 
        Select-Object LocalPort, @{Name = 'ProcessName'; Expression = { 
                try { (Get-Process -Id $_.OwningProcess).Name } catch { "N/A" }
            }
        }
    }
    catch {
        Write-Error "Failed to retrieve TCP connections: $_"
        return
    }
}