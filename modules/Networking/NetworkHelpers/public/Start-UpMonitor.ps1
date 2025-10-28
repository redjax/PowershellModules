function Start-UpMonitor {
    param(
        [string]$Site = "https://www.google.com",
        [string]$RequestSleep = 5
    )
    while ($true) {
        try {
            ## Make HTTP HEAD request
            $response = Invoke-WebRequest -Uri "$($Site)" -Method Head

            ## Output HTTP status code
            Write-Output "$(Get-Date) Ping site '$($Site)': [$($response.StatusCode): $($response.StatusDescription)]"
        } catch {
            Write-Error "$(Get-Date): Request failed. Error: $($_.Exception.Message)"
        }

        ## Pause for $RequestSleep seconds
        Start-Sleep -Seconds $RequestSleep
    }
}
