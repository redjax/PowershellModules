function Search-AzSiteExtensionInstalled {
    <#
        .SYNOPSIS
        This script finds Azure App Services with specific site extensions installed, such as Datadog.

        .DESCRIPTION
        This script retrieves a list of Azure App Services and checks each one for installed site extensions that match a specified string (default is "Datadog*"). It supports filtering by resource group and allows for parallel processing to speed up the checks.

        .PARAMETER ResourceGroup
        The name of the resource group to filter App Services. If not specified, all App Services will be checked.

        .PARAMETER ThrottleLimit
        The number of parallel threads to use for processing. Default is 10.

        .PARAMETER SiteExtensionString
        A full or partial string to match to site extension IDs. Defaults to "Datadog*". This allows you to specify which site extensions you are interested in finding.

        .EXAMPLE
        .\Search-AzSiteExtensionInstalled.ps1 -ResourceGroup "MyResourceGroup" -ThrottleLimit 5 -SiteExtensionString "Datadog*"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Specify the resource group to filter App Services.")]
        [string]$ResourceGroup,
        [Parameter(Mandatory = $false, HelpMessage = "Number of parallel threads to use for processing.")]
        [int]$ThrottleLimit = 10,
        [Parameter(Mandatory = $false, HelpMessage = "Full or partial string to match to site extension ID. Defaults to 'Datadog*'")]
        [string]$SiteExtensionString
    )

    if ( -Not $SiteExtensionString ) {
        Write-Warning "No site extension string specified. You must pass a full or partial extension string, i.e. -SiteExtensionString 'Datadog*'."
        return
    }

    Write-Host "`n[ Searching for App Services with site extensions matching: $($SiteExtensionString) ]`n" -ForegroundColor Magenta

    try {
        $Apps = Get-AppServices -ResourceGroup $ResourceGroup
    } catch {
        Write-Error "Failed to retrieve App Services. Ensure you are logged in to Azure CLI and the resource group exists."
        exit 1
    }

    ## Build flat list of all (App, Slot) pairs
    $AppSlotPairs = @()
    foreach ( $App in $Apps ) {
        ## Add production slot
        $AppSlotPairs += [PSCustomObject]@{ Name = $App.name; ResourceGroup = $App.rg; Slot = "production" }
        ## Add all deployment slots
        $Slots = az webapp deployment slot list --name $App.name --resource-group $App.rg -o json | ConvertFrom-Json
        foreach ( $slot in $Slots ) {
            if ( $slot.name -and $slot.name -ne "production" ) {
                $AppSlotPairs += [PSCustomObject]@{ Name = $App.name; ResourceGroup = $App.rg; Slot = $slot.name }
            }
        }
    }

    Write-Host "`n[ Found $( $AppSlotPairs.Count ) App Service slot(s) to check for site extension: $($SiteExtensionString) ]`n" -ForegroundColor Magenta

    Write-Host "Checking each App Service slot for site extension: $($SiteExtensionString)" -ForegroundColor Cyan
    ## Now scan all (App, Slot) pairs in parallel
    $Found = $AppSlotPairs | ForEach-Object -Parallel {
        $AppName = $_.Name
        $ResourceGroup = $_.ResourceGroup
        $SlotName = $_.Slot
        $SiteExtensionString = $using:SiteExtensionString

        try {
            ## Get correct publishing credentials for each slot
            if ( $SlotName -eq "production" ) {
                $Creds = az webapp deployment list-publishing-credentials --name $AppName --resource-group $ResourceGroup --query "{username:publishingUserName, password:publishingPassword}" -o json | ConvertFrom-Json
                $KuduUrl = "https://$AppName.scm.azurewebsites.net/api/siteextensions"
            } else {
                $Creds = az webapp deployment list-publishing-credentials --name $AppName --resource-group $ResourceGroup --slot $SlotName --query "{username:publishingUserName, password:publishingPassword}" -o json | ConvertFrom-Json
                $KuduUrl = "https://$AppName-$($SlotName).scm.azurewebsites.net/api/siteextensions"
            }

            ## Create auth header for Kudu API
            $Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($Creds.username):$($Creds.password)"))

            ## Query Kudu API for installed site extensions
            try {
                $exts = Invoke-RestMethod -Uri $KuduUrl -Headers @{ Authorization = "Basic $Auth" } -ErrorAction Stop
                if ( $exts | Where-Object { $_.id -like "*$SiteExtensionString" } ) {
                    [PSCustomObject]@{
                        Name          = $AppName
                        ResourceGroup = $ResourceGroup
                        Slot          = $SlotName
                    }
                }
            } catch {
                $ErrorResponse = $_.Exception.Response
                if ( $ErrorResponse ) {
                    $StatusCode = $ErrorResponse.StatusCode.value__
                    switch ( $StatusCode ) {
                        401 { Write-Warning "Unauthorized (401) when checking $AppName/$($SlotName): Check publishing credentials or permissions." }
                        403 { Write-Warning "Forbidden (403) when checking $AppName/$($SlotName): Check permissions, access restrictions, or if the site is stopped." }
                        404 { Write-Warning "Not Found (404) when checking $AppName/$($SlotName): The Kudu site or endpoint does not exist." }
                        default { Write-Error "HTTP error $StatusCode when checking $AppName/$($SlotName): $($_.Exception.Message)" }
                    }
                } else {
                    Write-Error "Error checking $AppName/$($SlotName): $($_.Exception.Message)"
                }
            }
        } catch {
            Write-Error "General error checking $AppName/$($SlotName): $($_.Exception.Message)"
        }
    } -ThrottleLimit $ThrottleLimit

    Write-Host "`n[ Results ]`n" -ForegroundColor Magenta
    ## Display results
    if ( $Found ) {
        Write-Host "Found $( $Found.Count ) App Service slot(s) with the site extension:" -ForegroundColor Green
        # $Found | Format-Table -AutoSize
        
        ## Return results if called programmatically
        return $Found
    } else {
        Write-Host "No App Services with the site extension found" -ForegroundColor Yellow
    }
}
