function Disable-DefenderRealtimeMonitoring {
    ## Helper function to check if the current user is an administrator
    function Test-Administrator {  
        $user = [Security.Principal.WindowsIdentity]::GetCurrent()
        (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
    }

    ## Check if the script is running as an administrator
    if ( -not ( Test-Administrator ) ) {
        Write-Warning "This script must be run as an administrator. Attempting to self-elevate..."

        ## Relaunch the script with elevated privileges
        $scriptPath = $MyInvocation.MyCommand.Path

        if ( -not $scriptPath ) {
            Write-Error "Unable to determine the script path. Please run this function as an administrator manually."
            return
        }

        try {
            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
            return
        }
        catch {
            Write-Error "Failed to self-elevate. Details: $($_.Exception.Message)"
            return
        }
    }

    ## If running as administrator, proceed with disabling Defender real-time monitoring
    Write-Output "Disabling Windows Defender Real-Time monitoring..."

    try {
        PowerShell Set-MpPreference -DisableRealtimeMonitoring 1
        Write-Output "Windows Defender Real-Time monitoring disabled."
    }
    catch {
        Write-Error "Failed to disable Windows Defender Real-Time monitoring. Details: $($_.Exception.Message)"
    }
}
