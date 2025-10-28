function Initialize-ScoopCli {
    <#
        .SYNOPSIS
        Initialize the Scoop CLI.

        .DESCRIPTION
        Installs aria2 & git, enables buckets.

        .PARAMETER ScoopBuckets
        Array of strings representing scoop buckets that should be enabled.

        .EXAMPLE
        Initialize-ScoopCli -ScoopBuckets @("extras", "nerd-fonts")
    #>
    param(
        [string[]]$ScoopBuckets = @("extras", "nerd-fonts")
    )

    if ( -Not ( Get-Command scoop -ErrorAction SilentlyContinue ) ) {
        Write-Warning "Scoop is not installed."

        do {
            $response = Read-Host "Install scoop CLI? [y/n]"

            switch ( $response.ToLower() ) {
                'y' {
                    Write-Output "Installing scoop CLI"
                    try {
                        Install-ScoopCli -ErrorAction Stop
                    } catch {
                        Write-Error "Error installing scoop CLI. Details: $($_.Exception.Message)"
                        Write-Warning "Check https://scoop.sh for instructions to install manually."

                        exit 1
                    }
                    break
                }
                'n' {
                    Write-Warning "Scoop is required to use this script. Please visit https://scoop.sh for installation instructions."
                    exit 1
                } default {
                    Write-Warning "Invalid input '$($response)'. Please respond with 'y' or 'n'."
                }
            }
        } while ( $response.ToLower() -notin @('y', 'n'))
    }

    Write-Output "Installing aria2 for accelerated downloads"
    
    try {
        scoop install aria2
        if (-not $(scoop config aria2-enabled) -eq $True) {
            scoop config aria2-enabled true
        }
    }
    catch {
        Write-Error "Failed to install aria2."
        Write-Error "Exception details: $($exc.Message)"
    }
    
    Write-Output "Enable scoop buckets"
    foreach ($Bucket in $ScoopBuckets) {
        try {
            scoop bucket add $Bucket
            Write-Output "Successfully added bucket: $Bucket"
        }
        catch {
            Write-Error "Failed to add bucket: $Bucket."
            Write-Error "Exception details: $($_.Exception.Message)"
        }
    }
    
    Write-Output "Disable scoop warning when using aria2 for downloads"
    try {
        scoop config aria2-warning-enabled false
    }
    catch {
        Write-Error "Failed to disable aria2 warning."
        Write-Error "Exception details: $($exc.Message)"
    }
    
    Write-Output "Install git"
    try {
        scoop install git
    }
    catch {
        Write-Error "Failed to install git."
        Write-Error "Exception details: $($exc.Message)"
    }
}
    