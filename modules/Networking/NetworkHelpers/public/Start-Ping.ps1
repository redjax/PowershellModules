function Start-Ping {
    <#
        .SYNOPSIS
        Ping a target host, IP, or FQDN. Control the number of times to ping, and the number of seconds to wait between pings.

        .PARAMETER Target
        The target hostname, IP, or FQDN to ping.

        .PARAMETER Count
        The number of times to ping. Default: 3, 0 for infinite.

        .PARAMETER Sleep
        The number of seconds to wait between pings. Default: 1

        .EXAMPLE
        Start-Ping -Target "google.com"

        .EXAMPLE
        Start-Ping -Target "server1" -Count 5

        .EXAMPLE
        Start-Ping -Target "192.168.1.1" -Count 5 -Sleep 2

        .EXAMPLE
        Start-Ping -t "192.168.1.13" -c 15 -s 5
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "The target hostname, IP, or FQDN to ping.")]
        [Alias("t")]
        [string]$Target,
        [Parameter(Mandatory = $false, HelpMessage = "The number of times to ping. Default: 3, 0 for infinite.")]
        [Alias("c")]
        [int]$Count = 3,
        [Parameter(Mandatory = $false, HelpMessage = "The number of seconds to wait between pings. Default: 1")]
        [Alias("s")]
        [int]$Sleep = 1
    )

    ## Function to return a formatted timestamp
    function Get-Timestamp {
        return Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    ## Function to format duration string
    ## Function to format duration string
    function Get-DurationString {
        Param(
            [Parameter(Mandatory = $false, HelpMessage = "The duration of the ping")]
            [TimeSpan]$Duration
        )

        ## Format the duration
        if ($Duration.TotalHours -lt 24) {
            ## Duration <24 hours
            $DurationStr = "{0:D2}:{1:D2}:{2:D2}" -f $Duration.Hours, $Duration.Minutes, $Duration.Seconds
        }
        else {
            ## Duration >24 hours
            $Days = [Math]::Floor($Duration.TotalDays)
            $Hours = $Duration.Hours
            $Minutes = $Duration.Minutes
            $Seconds = $Duration.Seconds
        
            $DurationStr = "$Days day(s) $Hours hour(s) $Minutes minute(s) $Seconds second(s)"
        }

        return $DurationStr
    }

    ## Function to print results message
    function Show-ResultsMessage {
        Param(
            [Parameter(Mandatory = $false, HelpMessage = "The start time of the ping")]
            [datetime]$StartTime,
            [Parameter(Mandatory = $false, HelpMessage = "The end time of the ping")]
            [datetime]$EndTime,
            [Parameter(Mandatory = $false, HelpMessage = "The target hostname, IP, or FQDN to ping.")]
            [string]$Target,
            [Parameter(Mandatory = $false, HelpMessage = "The total number of pings")]
            [int]$TotalPings,
            [Parameter(Mandatory = $false, HelpMessage = "The number of successful pings")]
            [int]$Successes,
            [Parameter(Mandatory = $false, HelpMessage = "The number of failed pings")]
            [int]$Failures
        )

        ## Calculate ping duration
        $PingDuration = New-TimeSpan -Start $StartTime -End $EndTime

        $DurationStr = Get-DurationString -Duration $PingDuration

        Write-Host "`n============[ PING RESULTS ]============`n" -ForegroundColor Yellow
        
        Write-Host "  Duration: " -NoNewline ; `
            Write-Host "$DurationStr" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Target: " -NoNewline ; `
            Write-Host "$Target " -ForegroundColor Cyan
        Write-Host "  Pings: " -NoNewline ; 
        Write-Host "$TotalPings" -ForegroundColor Blue
        Write-Host "  Successes: " -NoNewline ; `
            Write-Host "$Successes" -ForegroundColor Green
        Write-Host "  Failures: " -NoNewline ; `
            Write-Host "$Failures" -ForegroundColor Red

        Write-Host "`n========================================`n" -ForegroundColor Yellow
    }

    Write-Debug "Target: $Target"
    Write-Debug "Count: $Count"
    Write-Debug "Sleep: $Sleep"

    ## Store number of successful and failed pings
    $Successes = 0
    $Failures = 0

    ## Loop incrementor
    $i = 0

    ## Print different message based on inputs
    if ( $Count -gt 0 ) {
        Write-Host "Ping host: " -NoNewline ; `
            Write-Host "$Target" -ForegroundColor Cyan -NoNewline ; `
            Write-Host " ($Count time(s) | sleep duration: $Sleep)" -ForegroundColor Magenta
    }
    else {
        Write-Host "[$(Get-Timestamp)] Ping host: " -NoNewline ; `
            Write-Host "$Target" -ForegroundColor Cyan -NoNewline ; `
            Write-Host " (indefinite | sleep duration: $Sleep)" -ForegroundColor Magenta
    }

    ## Get start time
    $StartTime = Get-Date

    ## Loop pings
    try {
        while ($Count -eq 0 -or $i -lt $Count) {
            ## Increment counter
            $i++

            ## Build ping attempt string based on inputs
            if ($Count -gt 0) {
                $AttemptStr = "($i/$Count)"
            }
            else {
                $AttemptStr = "($i)"
            }

            ## Do ping
            try {
                $PingResult = Test-Connection -ComputerName $Target -Count 1 -Quiet -ErrorAction Stop
            }
            catch {
                Write-Warning "[$(Get-Timestamp)] $AttemptStr Network issues while pinging target: $Target. Error: $($_.Exception.Message)"

                $Failures++
                continue
            }

            ## Print success message
            if ($PingResult) {
                Write-Host "[$(Get-Timestamp)]" -NoNewline; `
                    Write-Host " [SUCCESS]" -ForegroundColor Green -NoNewline; `
                    Write-Host " $AttemptStr Reply from " -NoNewline ; 
                Write-Host "$($Target)" -ForegroundColor Cyan

                ## Increment success counter
                $Successes++
            }
            ## Print failure message
            else {
                Write-Host "[$(Get-Timestamp)]" -NoNewline; `
                    Write-Host " [FAILURE]" -ForegroundColor Red -NoNewline; `
                    Write-Host " $AttemptStr No reply from "-NoNewline ; 
                Write-Host "$($Target)" -ForegroundColor Cyan

                ## Increment failure counter
                $Failures++
            }

            if ( $Sleep -gt 0 ) {
                ## Pause for sleep duration
                Start-Sleep -Seconds $Sleep
            }
        }
    }
    catch {
        Write-Host "Error while pinging $Target : $($_.Exception.Message)"
    }
    finally {
        $EndTime = Get-Date

        Show-ResultsMessage -Target $Target -TotalPings $i -Successes $Successes -Failures $Failures -StartTime $StartTime -EndTime $EndTime
    }
}
