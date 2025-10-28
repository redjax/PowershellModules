function Convert-ToLowercase {
    <#
        .SYNOPSIS
        Convert a string to all lowercase.

        .PARAM InputString
        The string to convert to lowercase.

        .EXAMPLE
        Convert-ToLowercase -InputString "Hello World"
    #>
    param(
        $InputString = $null
    )

    if (-not $InputString) {
        Write-Warning "Missing an -InputString to set to lowercase"
    }

    ## Return lowercased string
    "$($InputString)".ToLower()
}