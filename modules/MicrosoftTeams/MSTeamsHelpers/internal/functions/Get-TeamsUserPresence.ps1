function Get-TeamsUserPresence {
    <#
        .SYNOPSIS
        Get user's Teams presence
    #>
    param (
        [string]$UPN
    )

    try {
        $user = Get-MgUser -UserId $UPN
        $presence = Get-MgUserPresence -UserId $user.Id
        [PSCustomObject]@{
            UPN          = $UPN
            Availability = $presence.Availability
            Activity     = $presence.Activity
        }
    }
    catch {
        Write-Warning "Failed to get presence for $($UPN): $_"
        [PSCustomObject]@{
            UPN          = $UPN
            Availability = "Error"
            Activity     = "Error"
        }
    }
}