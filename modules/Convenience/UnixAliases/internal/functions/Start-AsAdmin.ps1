function Start-AsAdmin {
    <#
        .SYNOPSIS
        Pipe a command through an elevated Powershell prompt.

        .PARAMETER Command
        The Powershell command to run in the elevated shell.
    #>
    param(
        [string]$Command
    )

    ## Check if the script is running as admin
    $isAdmin = [bool](New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        ## Prompt to run as administrator if not already running as admin
        $arguments = "-Command `"& {$command}`""
        Write-Debug "Running command: Start-Process powershell -ArgumentList $($arguments) -Verb RunAs"

        try {
            Start-Process powershell -ArgumentList $arguments -Verb RunAs
            return $true
        }
        catch {
            Write-Error "Error executing command as admin. Details: $($_.Exception.Message)"
        }
    }
    else {
        ## If already running as admin, execute the command
        Invoke-Expression $command
        return $false
    }
}