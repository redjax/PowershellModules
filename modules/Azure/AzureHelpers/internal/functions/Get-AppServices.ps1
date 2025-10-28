function Get-AppServices {
    <#
            .SYNOPSIS
            List all App Services if no resource group is specified, or list App Services in a specific resource group.

            .DESCRIPTION
            This function retrieves a list of App Services in Azure. If a resource group is specified, it filters the App Services to only those within that resource group. If no resource group is specified, it retrieves all App Services across all resource groups.

            .PARAMETER ResourceGroup
            The name of the resource group to filter App Services. If not specified, all App Services will be retrieved.
        #>
    Param(
        [string]$ResourceGroup
    )

    ## Get all App Services, filtered by resource group if specified
    if ( $ResourceGroup ) {
        Write-Host "Getting list of App Services in resource group '$ResourceGroup' (this can take a while)" -ForegroundColor Cyan
        try {
            return az webapp list --resource-group $ResourceGroup --query "[].{name:name, rg:resourceGroup}" -o json | ConvertFrom-Json
        }
        catch {
            Write-Error "Failed to retrieve App Services in resource group '$ResourceGroup'"
            exit 1
        }
        ## No resource group specified, get all App Services
    }
    else {
        Write-Host "Getting list of all App Services" -ForegroundColor Cyan
        try {
            return az webapp list --query "[].{name:name, rg:resourceGroup}" -o json | ConvertFrom-Json
        }
        catch {
            Write-Error "Failed to retrieve App Services"
            exit 1
        }
    }
}