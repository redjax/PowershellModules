function Get-KuduUrl {
    <#
        .SYNOPSIS
        Return the Kudu URL for the given Azure App Service.

        .DESCRIPTION
        This function constructs the Kudu URL for an Azure App Service based on the provided App Service name.

        .PARAMETER AppServiceName
        The name of the Azure App Service for which to return the Kudu URL.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Name of the Azure App Service to return a Kudu URL for.")]
        [string]$AppServiceName = $(throw "AppServiceName is required.")
    )

    $KuduUrl = "https://$AppServiceName.scm.azurewebsites.net/DebugConsole"

    $KuduUrl
}
