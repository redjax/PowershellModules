function sudo {
    param(
        [string]$command
    )

    try {
        Start-AsAdmin $command
    }
    catch {
        Write-Error "Failed to run command as admin. Details: $($_.Exception.Message)"
        return $false
    }

    return $true
}
