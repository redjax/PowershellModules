function Get-PlatformServices {
    <#
        .SYNOPSIS
        Return information about system services.
    #>
    try {
        $Services = Get-Service | Select-Object -Property `
            Name, `
            DisplayName, `
            Status, `
            StartType, `
            ServiceType, `
            ServiceName, `
            MachineName , `
            DependentServices, `
            ServicesDependedOn
    }
    catch {
        Write-Error "Error retrieving services. Details: $($_.Exception.Message)"
    }

    $Services
}
