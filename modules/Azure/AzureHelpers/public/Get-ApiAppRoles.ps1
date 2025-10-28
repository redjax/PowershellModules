function Get-ApiAppRoles {
    if ( -Not ( Get-Command az -ErrorAction SilentlyContinue ) ) {
        Throw "The Azure CLI is not installed. Please install the Azure CLI to use this function."
    }

    $appList = az ad app list  --query "[?contains(appRoles[].value, 'ApiAppRole') && length(passwordCredentials[])]" --all  | ConvertFrom-Json | Sort-Object { $_.passwordCredentials.endDateTime }
    if ( $appList.Count -eq 0 ) {
        Write-Host "No API apps with roles found." -ForegroundColor Yellow
        return @()
    } elseif ( $LASTEXITCODE -ne 0 ) {
        Throw "Failed to retrieve API apps. Please ensure you are logged in to Azure CLI and have the necessary permissions."
    } else {
        $appList
    }
}