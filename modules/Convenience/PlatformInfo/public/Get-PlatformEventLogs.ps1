function Get-PlatformEventLogs {
    <#
        .SYNOPSIS
        Retrieve recent entries from the system event logs.
    #>
    param (
        [Parameter(Mandatory = $false, HelpMessage = "The maximum number of entries to retrieve. Default: 50")]
        [int]$MaxEntries = 50
    )
    
    try {
        $Events = Get-EventLog -LogName System -Newest $MaxEntries | Select-Object -Property `
            TimeGenerated, `
            EntryType, `
            Source, `
            Message, `
            EventID, `
            Category, `
            CategoryNumber, `
            Index, `
            ReplacementStrings, `
            UserName
    }
    catch {
        Write-Error "Error retrieving event logs. Details: $($_.Exception.Message)"
    }

    $Events
}
