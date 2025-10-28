function Get-PlatformEnvironment {
    <#
        .SYNOPSIS
        Return environment variables for the current session.
    #>
    try {
        $Env = [System.Environment]::GetEnvironmentVariables()
    }
    catch {
        Write-Error "Error retrieving environment variables. Details: $($_.Exception.Message)"
    }

    $Env
}
