function Start-ADModuleInstall {
    try {
        Install-ActiveDirectoryModule
    }
    catch {
        Write-Error "Error installing Active Directory PowerShell module. Details: $($_.Exception.Message)"
        exit 1
    }
}