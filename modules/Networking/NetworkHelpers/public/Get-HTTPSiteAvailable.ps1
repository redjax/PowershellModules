function Get-HTTPSiteAvailable {
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "The website to ping/request. Default: https://www.google.com")]
        [string]$Site = "https://www.google.com",
        [Parameter(Mandatory = $false, HelpMessage = "The number of seconds to wait between requests. Default: 5")]
        [int]$Sleep = 5,
        [Parameter(Mandatory = $false, HelpMessage = "The number of requests to make. Default: 0 (infinite)")]
        [int]$Count = 0,
        [Parameter(Mandatory = $false, HelpMessage = "The HTTP method to use. Default: Head")]
        [string]$Method = "Head"
    )

    $Counter = 0
    $SuccessCount = 0
    $FailureCount = 0

    while ( ($Count -eq 0) -or ($Counter -lt $Count) ) {
        try {
            ## Make HTTP request
            $response = Invoke-WebRequest -Uri $Site -Method $Method

            ## Format output with correct counter
            if ($Count -gt 0) {
                $CountStr = "[$($Counter + 1)/$Count]"
            }
            else {
                $CountStr = "[$($Counter + 1)]"
            }

            ## Display result
            Write-Host "$(Get-Date) Ping site '$Site': [$($response.StatusCode): $($response.StatusDescription)]"

            ## Increment successful request counter
            $SuccessCount++
        }
        catch {
            Write-Host "$(Get-Date): Request failed. Error: $($_.Exception.Message)" -ForegroundColor Red

            ## Increment failed request counter
            $FailureCount++
        }
        finally {
            Write-Output "$($CountStr) [Success: $SuccessCount, Failures: $FailureCount]"
        }

        ## Increment counter correctly
        $Counter++

        if ( $Count -eq 0) {
            ## Pause before next request
            Start-Sleep -Seconds $Sleep
        }
        elseif ( $Counter -lt $Count) {
            ## Pause before next request
            Start-Sleep -Seconds $Sleep
        }        
    }

    Write-Output "`nFinished pinging '$($Site)'`nSuccesses: $($SuccessCount), Failures: $($FailureCount)`n"
}