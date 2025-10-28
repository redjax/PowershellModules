function Get-Weather {
    <#
        .SYNOPSIS
        Retrieve weather information from wttr.in

        .DESCRIPTION
        Retrieve weather information from wttr.in using Invoke-Restmethod. Customize with params like -Location, -Units, etc.

        To see available formats, visit https://wttr.in/:help, or check their Github repository: https://github.com/chubin/wttr.in

        .PARAMETER Location
        The location to retrieve weather for. Default: current location

        .PARAMETER Units
        The measurement units to use. u=US, m=metric, M=metric (wind only)

        .PARAMETER Language
        A 2-character language code, i.e. 'en' or 'es'

        .PARAMETER Format
        The output format to use. 1-4, or another format (see all with -Help)

        .PARAMETER PNG
        If set, retrieve weather as PNG image

        .PARAMETER Help
        Request wttr.in help page

        .EXAMPLE
        Get-Weather -Location "New York" -Units "M"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = "The location to retrieve weather for. Default: current location")]
        [string]$Location = "",
        [Parameter(Mandatory = $false, HelpMessage = "The measurement units to use. u=US, m=metric, M=metric (wind only)")]
        [string]$Units = "",
        [Parameter(Mandatory = $false, HelpMessage = "A 2-character language code, i.e. 'en' or 'es'")]
        [ValidatePattern('^[a-z]{2}$')]
        [string]$Language = "",
        [Parameter(Mandatory = $false, HelpMessage = "The output format to use. 1-4, or another format (see all with -Help)")]
        [string]$Format = "%c+It+is+%C+in+%l+(%T+%Z)+\n+\n+Temp.:+%t+(actual)+%f+(feels+like)+\n+Humidity:+%h+\n+Wind:+%w+\n+Moon:+%m+(Moon+day:%M)+\n+Precipitation+(mm/3+hrs):+%p+\n+Pressure:+%P+\n+UV+Index:+%u\n+\nDawn:+%D+\n+Sunrise:+%S+\n+Zenith:%z+\n+Sunset:+%s+\n+Dusk:+%d",
        [Parameter(Mandatory = $false, HelpMessage = "If set, retrieve weather as PNG image")]
        [switch]$PNG,
        [Parameter(Mandatory = $false, HelpMessage = "Request help page")]
        [switch]$Help,
        [Parameter(Mandatory = $false, HelpMessage = "Also show forecast")]
        [switch]$Forecast
    )
    
    $baseUrl = "https://wttr.in"

    ## Override method if -Help passed
    if ( $Help ) {
        $Url = "$($BaseUrl)/:help"
        Invoke-RestMethod -Uri $Url

        return
    }
    
    ## Construct the location part of the URL
    if ( $Location ) {
        $locationPath = "/$($Location -replace ' ', '+')"
    }
    else {
        $locationPath = ""
    }
    ## Construct the query parameters
    $queryParams = @()
    if ($Units) { $queryParams += $Units }
    
    if ( $Format ) { $queryParams += "format=$Format" }
    
    if ($Language) { $queryParams += "lang=$Language" }
    
    ## If PNG is requested, modify the URL accordingly
    if ($PNG) {
        $url = "$baseUrl$locationPath""_$(($queryParams -join '') -replace '[?&]', '_').png" 
    }
    else {
        $url = "$baseUrl$locationPath"
        if ($queryParams.Count -gt 0) {
            $url += "?" + ($queryParams -join "&")
        }
    }

    if ( $Forecast ) {
        $url = "$($baseUrl)/$($Location)"
    }
    
    If ( $Location ) {
        Write-Information "Fetching weather for $Location"
        Invoke-RestMethod -Uri $url
        return
    }
    else {
        Write-Information "Fetching weather from wttr.in"
    }
    
    if ( $PNG ) {
        Start-Process $url
    }
    else {
        Invoke-RestMethod -Uri $url
        return
    }
}