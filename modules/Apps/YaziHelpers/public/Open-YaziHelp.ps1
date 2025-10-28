function Open-YaziHelp {
    <#
        .SYNOPSIS
        Opens the Yazi help webpage

        .DESCRIPTION
        Opens the Yazi help webpage in your default browser using the `Start-Process` cmdlet

        .EXAMPLE
        Open-YaziHelp
    #>
    try {
        Start-Process "https://yazi-rs.github.io/docs/quick-start"
    }
    catch {
        Write-Error "Failed to open Yazi help page. Details: $($_.Exception.Message)"
        exit 1
    }
}