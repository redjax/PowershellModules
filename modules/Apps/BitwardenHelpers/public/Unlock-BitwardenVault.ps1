function Unlock-BitwardenVault {
    <#
        .SYNOPSIS
        Unlock Bitwarden vault & store session token in $env:BW_SESSION.

        .DESCRIPTION
        This function uses the 'bw unlock' command to unlock the Bitwarden vault and stores the session token in the $env:BW_SESSION environment variable.
        Until the vault is locked or the termina is closed, this token will authenticate requests to the Bitwarden API, meaning you won't have to
        re-type your master password every time.

        .EXAMPLE
        Unlock-BitwardenVault
    #>

    ## Run the 'bw unlock' command and capture the output
    $Output = bw unlock

    # Initialize an empty session token
    $sessionToken = $null

    ## Loop through each line of the output to find the session token
    foreach ( $line in $Output ) {
        if ($line -match '^\> \$env:BW_SESSION="([^"]+)"') {
            $sessionToken = $matches[1]
            break
        }
    }

    ## Check if the session token was found
    if ($sessionToken) {
        ## Set the BW_SESSION environment variable in the current shell session
        $env:BW_SESSION = $sessionToken
        Write-Output "BW_SESSION has been set."
    }
    else {
        Write-Output "Failed to capture the session token."
    }
}
