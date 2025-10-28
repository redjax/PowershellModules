function Get-PlatformLastBoot {
    <#
        .SYNOPSIS
        Return last system boot date
    #>
    try {
        # Get the last boot-up time of the system
        $LastBootUpTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    }
    catch {
        # Handle errors gracefully and provide meaningful output
        Write-Error "Error retrieving system uptime. Details: $($_.Exception.Message)"
    }

    $LastBootUpTime
}
