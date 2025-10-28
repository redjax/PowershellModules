function Convert-ToBase64Encoded {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "The string to be encoded.")]
        [string]$String
    )

    if ( -Not $String ) {
        Write-Error "The string cannot be null or empty."
        return
    }

    try {
        ## Convert input string to bytes
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
    } catch {
        Write-Error "Failed to convert string to bytes: $_"
        return
    }

    try{
        ## Base64 encode bytes
        $encodedString = [Convert]::ToBase64String($bytes)
    } catch {
        Write-Error "Failed to encode bytes to Base64: $_"
        return
    }

    $encodedString
}