function Set-OutlookOOO {
    <#
        .SYNOPSIS
        Sets an Outlook Out of Office (OOO) message for a user.

        .DESCRIPTION
        This function sets an Outlook Out of Office (OOO) message for a user. It requires the ExchangeOnlineManagement module to be installed and the user to have the necessary permissions to set OOO messages.

        .PARAMETER Identity
        The identity of the user for whom the OOO message is being set. This should be in the format 'DOMAIN\username'. By default, the script will use the identity of the user executing it.

        .PARAMETER UPN
        The Exchange UPN for the user (i.e. username@domain.com) to set the OOO message for.

        .PARAMETER AutoReplyState
        The state of the auto-reply. Default is 'Scheduled'.

        .PARAMETER StartTime
        The date/time to start the OOO schedule. Value should be a quoted string, i.e. 'YYYY-MM-dd hh:mm tt'.

        .PARAMETER EndTime
        The date/time to end the OOO schedule. Value should be a quoted string, i.e. 'YYYY-MM-dd hh:mm tt'.

        .PARAMETER InternalMessageFile
        Path to a .txt file containing the internal OOO message you want to apply.

        .PARAMETER ExternalMessageFile
        Path to a .txt file containing the external OOO message you want to apply.

        .PARAMETER Apply
        When the script is run without -Apply, message will only be displayed, not applied.

        .EXAMPLE
        Set-OutlookOOO -UPN "youremail@domain.com" -StartTime "202X-01-01 08:00 AM" -EndTime "202X-01-02 05:00 PM" -InternalMessageFile "C:\path\to\internal.txt" -ExternalMessageFile "C:\path\to\external.txt" -Apply
    #>
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Please enter your username in the format 'DOMAIN\username")]
        [string]$Identity = "$env:USERDOMAIN\$env:USERNAME",
        [Parameter(Mandatory = $false, HelpMessage = "The Exchange UPN for your user (i.e. username@domain.com)")]
        [string]$UPN,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the autoreply state (default: Scheduled)")]
        [string]$AutoReplyState = "Scheduled",
        [Parameter(Mandatory = $false, HelpMessage = "The date/time to start the OOO schedule. Value should be a quoted string, i.e. 'YYYY-MM-dd hh:mm tt'")]
        [datetime]$StartTime,
        [Parameter(Mandatory = $false, HelpMessage = "The date/time to end the OOO schedule. Value should be a quoted string, i.e. 'YYYY-MM-dd hh:mm tt'")]
        [datetime]$EndTime,
        [Parameter(Mandatory = $false, HelpMessage = "Path to a .txt file containing the internal OOO message you want to apply.")]
        [string]$InternalMessageFile,
        [Parameter(Mandatory = $false, HelpMessage = "Path to a .txt file containing the external OOO message you want to apply.")]
        [string]$ExternalMessageFile,
        [Parameter(Mandatory = $false, HelpMessage = "When `$false, message will only be displayed, not applied.")]
        [switch]$Apply = $false
    )

    ## Check if the ExchangeOnlineManagement module is installed
    if ( -Not ( Get-Module -ListAvailable | Where-Object { $_.Name -like "ExchangeOnlineManagement" } ) ) {
        Write-Error "ExchangeOnlineManagement module not found. Please install with: Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force"
        return
    }

    ## Check that an identity was passed
    if ( -Not $Identity ) {
        Write-Error "Missing identity to apply the OOO message to."
        return
    }

    ## Check that a UPN was passed
    if ( -Not $UPN ) {
        Write-Error "Missing an Exchange user UPN (i.e. user@domain.com)."
        return
    }

    ## Set defaults for internal/external message file if not provided
    if (-not $InternalMessageFile) {
        $InternalMessageFile = Join-Path -Path $PSScriptRoot -ChildPath 'messages/internal-default.txt'
    }
    if (-not $ExternalMessageFile) {
        $ExternalMessageFile = Join-Path -Path $PSScriptRoot -ChildPath 'messages/external-default.txt'
    }

    ## Ensure message file exists
    if ( -Not ( Test-Path $InternalMessageFile ) ) {
        Write-Error "Internal message file '$InternalMessageFile' does not exist."
        return
    }

    ## Load message contents
    $InternalMessageText = Get-Content $InternalMessageFile -Raw
    $ExternalMessageText = Get-Content $ExternalMessageFile -Raw

    ## Normalize line endings
    $InternalMessageText = "<html><body>" + ($InternalMessageText -Replace "`r`n", "<br>") + "</body></html>"
    $ExternalMessageText = "<html><body>" + ($ExternalMessageText -Replace "`r`n", "<br>") + "</body></html>"

    ## Replace placeholder with provided values
    $FormattedEndDate = $EndTime.ToString("MM/dd/yy")

    if ($InternalMessageText -match '\[date of your return\]') {
        $InternalMessageText = $InternalMessageText -replace '\[date of your return\]', $FormattedEndDate
    }
    else {
        Write-Warning "Placeholder '[date of your return]' not found in message file."
    }

    if ($ExternalMessageText -match '\[date of your return\]') {
        $ExternalMessageText = $ExternalMessageText -replace '\[date of your return\]', $FormattedEndDate
    }
    else {
        Write-Warning "Placeholder '[date of your return]' not found in message file."
    }

    Write-Host "Scheduled internal message text:`n" -ForegroundColor Cyan -NoNewline; Write-Host "$($InternalMessageText)"
    Write-Host "Scheduled external message text:`n" -ForegroundColor Cyan -NoNewline; Write-Host "$($ExternalMessageText)"

    if ( $Apply ) {
        ## Import ExchangeOnlineManagement module
        try {
            Import-Module ExchangeOnlineManagement
        }
        catch {
            Write-Error "Error importing module ExchangeOnlineManagement. Details: $($_.Exception.Message)"
            return
        }

        if ( -Not ( Get-Module ExchangeOnlineManagement ) ) {
            Write-Error "Could not import ExchangeOnlineManagement module."
            return
        }

        ## Connect to Exchange
        Write-Host "Connecting to Exchange..." -ForegroundColor Cyan
        try {
            Connect-ExchangeOnline -UserPrincipalName $UPN -ShowProgress $true
        }
        catch {
            Write-Error "Error connecting to Exchange online. Details: $($_.Exception.Message)"
            return
        }

        Write-Host "Setting Outlook OOO message"
        try {
            Set-MailboxAutoReplyConfiguration `
                -Identity $Identity `
                -AutoReplyState $AutoReplyState `
                -StartTime $StartTime `
                -EndTime $EndTime `
                -InternalMessage $InternalMessageText `
                -ExternalMessage $ExternalMessageText
        }
        catch {
            Write-Error "Unable to set Outlook OOO message. Details: $($_.Exception.Message)"
            return
        }

        Write-Host "Outlook OOO message set successfully."
        return
    }
    else {
        Write-Warning "-Apply = `$false, OOO message will not be applied"
        return
    }
}