function Convert-ToUppercase {
    <#
        .SYNOPSIS
        Convert a string to all uppercase.

        .PARAM InputString
        The string to convert to uppercase.

        .EXAMPLE
        Convert-ToUppercase -InputString "Hello World"
    #>
    param(
        $InputString = $null
    )

    if (-not $InputString) {
        Write-Warning "Missing an -InputString to set to uppercase"
    }

    ## Return uppercased string
    "$($InputString)".ToUpper()
}