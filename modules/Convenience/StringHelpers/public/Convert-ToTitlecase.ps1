function Convert-ToTitlecase {
    <#
        .SYNOPSIS
        Convert a string to titlecase.  

        .PARAM InputString
        The string to convert to titlecase.

        .EXAMPLE
        Convert-ToTitlecase -InputString "hello world"
    #>
    param(
        $InputString = $null
    )

    if (-not $InputString) {
        Write-Warning "Missing an -InputString to set to title case"
    }

    ## Extract and format text from string
    $culture = [System.Globalization.CultureInfo]::CurrentCulture
    $textInfo = $culture.TextInfo

    ## Return title-cased string
    $textInfo.ToTitleCase($InputString.ToLower())
}