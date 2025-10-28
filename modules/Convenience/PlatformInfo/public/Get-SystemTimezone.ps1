function Get-SystemTimeZone {
    <#
        .SYNOPSIS
        Return the current system time zone settings.
    #>
    
    try {
        $Timezone = [System.TimeZoneInfo]::Local | Select-Object `
            Id, `
            DisplayName, `
            BaseUtcOffset, `
            SupportsDaylightSavingTime, `
            StandardName, `
            DaylightName            
    }
    catch {
        Write-Error "Error retrieving time zone information."
    }

    return $Timezone
}
