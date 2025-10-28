function Get-TeamsPresence {
    <#
        .SYNOPSIS
        Get the presence/status of a Teams user or array of Teams users.

        .DESCRIPTION
        Query a user/array of users' Teams presence/status using the Microsoft Graph API.

        .PARAMETER UPNs
        Array of usernames to monitor presence (username@domain.tld)

        .PARAMETER LoopSleep
        Number of seconds between each loop

        .PARAMETER Repeat
        Number of times to run the loop (default: 1, use -Result 0 for infinite loop)

        .EXAMPLE
        Get-TeamsPresence -UPNs @("username@domain.tld", "username2@domain.tld") -LoopSleep 30 -Repeat 3
    #>
    Param(
        [CmdletBinding()]
        ## Enforce UPN format
        [ValidatePattern("^[^@]+@[^@]+\.[^@]+$")]
        [Parameter(Mandatory = $false, HelpMessage = "Array of usernames to monitor presence (username@domain.tld)")]
        $UPNs = @(),
        [Parameter(Mandatory = $false, HelpMessage = "Number of seconds between each loop")]
        $LoopSleep = 60,
        [Parameter(Mandatory = $false, HelpMessage = "Number of times to run the loop (default: 1, use -Result 0 for infinite loop)")]
        $Repeat = 1
    )

    ## Modules required for this script
    $RequiredModules = @("Microsoft.Graph.Users")

    ## Validate input user IDs
    if ( ( -not ( $UPNs ) ) -or ( $UPNs.Count -eq 0 ) ) {
        Write-Error "-UPNs cannot be `$null, and must have at least 1 user, i.e. -UPNs @('username@domain.tld')"
        exit(1)
    }

    ## Force module cache refresh
    # $null = Get-Module -ListAvailable -Refresh

    # function Get-TeamsUserPresence {
    #     <#
    #         .SYNOPSIS
    #         Get user's Teams presence
    #     #>
    #     param (
    #         [string]$UPN
    #     )

    #     try {
    #         $user = Get-MgUser -UserId $UPN
    #         $presence = Get-MgUserPresence -UserId $user.Id
    #         [PSCustomObject]@{
    #             UPN          = $UPN
    #             Availability = $presence.Availability
    #             Activity     = $presence.Activity
    #         }
    #     }
    #     catch {
    #         Write-Warning "Failed to get presence for $($UPN): $_"
    #         [PSCustomObject]@{
    #             UPN          = $UPN
    #             Availability = "Error"
    #             Activity     = "Error"
    #         }
    #     }
    # }

    ## Check for required modules
    # foreach ( $module in $requiredModules ) {
    #     if ( -not ( Get-Module -ListAvailable -Name $module ) ) {
    #         Write-Warning "$module not installed. Installing..."
    #         try {
    #             Install-Module -Name $module -Scope CurrentUser -AllowClobber -Force
    #             Write-Host "$module installed successfully." -ForegroundColor Green
    #         }
    #         catch {
    #             Write-Error "Failed to install $($module): $($_.Exception.Message)"
    #             exit 1
    #         }
    #     }
    #     else {
    #         Write-Host "$module is already installed." -ForegroundColor Cyan
    #     }

    #     Import-Module $module -Force
    # }
    try {
        Install-RequiredModules -RequiredModules $RequiredModules
    }
    catch {
        Write-Error "Error occurred while installing a required module. Details: $($_.Exception.Message)"
        exit 1
    }

    ## Import Microsoft Graph
    Write-Host "Importing Microsoft.Graph modules" -ForegroundColor Cyan
    try {
        Import-Module Microsoft.Graph.Users -Force
    }
    catch {
        Write-Error "Error importing Microsoft.Graph module. Details: $($_.Exception.Message)"
    }

    ## Authenticate to Microsoft Graph
    # Write-Host "Authenticating to Microsoft Graph (finish in browser)" -ForegroundColor Cyan
    # try {
    #     Connect-MgGraph -Scopes "Presence.Read.All, User.Read.All" -ErrorAction Stop -NoWelcome
    #     ## Get current authentication context
    #     $Context = Get-MgContext

    #     Write-Debug "Scopes:`n$($Context.Scopes -join ', ')"
    # }
    # catch {
    #     Write-Error "Authentication failed: $($_.Exception.Message)"
    #     exit(1)
    # }
    try {
        $Context = Start-MsGraphAuthentication
    }
    catch {
        Write-Error "Error authenticating to Microsoft Graph. Details: $($_.Exception.Message)"
        exit 1
    }

    ## Confirm Graph connection
    Write-Debug "Microsoft Graph context:`n$(Get-MgContext | Format-List)"

    ## Check if Presence.Read.All is granted
    if ( -not ( ( $Context.Scopes -contains "Presence.Read.All" ) -and ( $Context.Scopes -contains "User.Read.all" ) ) ) {
        Write-Error "Presence.Read.All and User.Read.All permissions required. Actual scopes: $($Context.Scopes)"
        exit(1)
    }

    ## Get presence for each UPN on a loop
    $i = 1
    while ($true) {
        if ($Repeat -ne 0 -and $i -gt $Repeat) {
            break
        }

        if ( $Repeat -eq 0 ) {
            $LoopRepeatString = " Loop $i (infinite)"
        }
        elseif ( $Repeat -eq 1 ) {
            $LoopRepeatString = $null
        }
        else {
            $LoopRepeatString = " Loop $i"
        }

        Write-Host "`n[$(Get-Date -Format T)]$($LoopRepeatString): Getting presence for $($UPNs.Count) UPN(s)" -ForegroundColor Cyan

        $results = foreach ($upn in $UPNs) {
            try {
                Get-TeamsUserPresence -UPN $upn
            }
            catch {
                Write-Error "Error getting presence for UPN: $($upn). Details: $($_.Exception.Message)"
                continue
            }
        }

        Write-Host "`n--[ Results: (Loop #$i) ]--`nRetrieved $($results.Count) presence(s)." -ForegroundColor Green
        $results | Format-Table -AutoSize

        if ($Repeat -eq 0 -or $i -lt $Repeat) {
            Write-Host "`nSleeping for $LoopSleep second(s)..." -ForegroundColor Yellow
            Start-Sleep -Seconds $LoopSleep
        }

        $i++
    }
}