function Install-ActiveDirectoryModule {
    ## Test is the Unlock-ADAccount function exists, indicating the AD module is installed
    if ( Get-Command Unlock-ADAccount ) {
        Write-Output "The Unlock-ADAccount command is available, the ActiveDirectory module is installed already."
        return
    }

    Write-Output "Installing the ActiveDirectory module."
    try {
        Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
    }
    catch {
        Write-Error "Unable to enable RSAT Windows features (which add the ActiveDirectory PowerShell module). Details: $($_.Exception.Message)"
        exit 1
    }
}