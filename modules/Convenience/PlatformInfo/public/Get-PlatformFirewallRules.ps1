function Get-PlatformFirewallRules {
    <#
        .SYNOPSIS
        Return Windows Firewall rules.
    #>
    try {
        $Rules = Get-NetFirewallRule | Select-Object -Property `
            Name, `
            DisplayName, `
            Enabled, `
            Action, `
            Direction, `
            Profile, `
            Description, `
            Group, `
            EdgeTraversalPolicy
    }
    catch {
        Write-Error "Error retrieving firewall rules. Details: $($_.Exception.Message)"
    }

    $Rules
}
