function Install-ScoopCli {
    <#
        .SYNOPSIS
        Install the scoop CLI from https://scoop.sh
    #>

    if ( -not ( Get-Command scoop ) ) {
        Write-Output "Installing scoop from https://get.scoop.sh"

        try {
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression -ErrorAction SilentlyContinue
        }
        catch {
            Write-Error "Failed to install scoop."
            Write-Error "Exception details: $($exc.Message)"
            exit 1
        }
    }
    else {
        Write-Warning "Scoop is already installed. Run scoop --help for usage."
    }
}