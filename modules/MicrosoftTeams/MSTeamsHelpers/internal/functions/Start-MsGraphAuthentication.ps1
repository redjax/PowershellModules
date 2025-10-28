function Start-MsGraphAuthentication {
    Write-Host "Authenticating to Microsoft Graph (finish in browser)" -ForegroundColor Cyan
    try {
        Connect-MgGraph -Scopes "Presence.Read.All, User.Read.All" -ErrorAction Stop -NoWelcome
        ## Get current authentication context
        $Context = Get-MgContext

        Write-Debug "Scopes:`n$($Context.Scopes -join ', ')"
    }
    catch {
        Write-Error "Authentication failed: $($_.Exception.Message)"
        exit(1)
    }

    $Context
}