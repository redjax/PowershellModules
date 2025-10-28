function Install-RequiredModules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = "Array of Powershell modules required to run the script")]
        [string[]]$RequiredModules = @("Microsoft.Graph.Users")
    )

    ## Force module cache refresh
    $null = Get-Module -ListAvailable -Refresh
    
    ## Check for required modules
    foreach ( $module in $RequiredModules ) {
        if ( -not ( Get-Module -ListAvailable -Name $module ) ) {
            Write-Warning "$module not installed. Installing..."
            try {
                Install-Module -Name $module -Scope CurrentUser -AllowClobber -Force
                Write-Host "$module installed successfully." -ForegroundColor Green
            }
            catch {
                Write-Error "Failed to install $($module): $($_.Exception.Message)"
                exit 1
            }
        }
        else {
            Write-Host "$module is already installed." -ForegroundColor Cyan
        }

        Import-Module $module -Force
    }
}