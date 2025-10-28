function uptime {
    ## Mimic Unix 'uptime' command in PowerShell

    try {
        $OS = Get-WmiObject Win32_OperatingSystem -ComputerName $env:COMPUTERNAME -ErrorAction Stop
        $Uptime = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime)
        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            LastBoot     = $OS.ConvertToDateTime($OS.LastBootUpTime)
            Uptime       = ([String]$Uptime.Days + " Days " + $Uptime.Hours + " Hours " + $Uptime.Minutes + " Minutes")
        } | Format-Table
 
    }
    catch {
        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            LastBoot     = "Unable to Connect"
            Uptime       = $_.Exception.Message.Split('.')[0]
        }
 
    }
    finally {
        $null = $OS
        $null = $Uptime
    }
}
