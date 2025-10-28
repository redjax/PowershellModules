function Get-PlatformProcesses {
    <#
        .SYNOPSIS
        Return a list of running processes.
    #>
    try {
        $Processes = Get-WmiObject Win32_Process | Select-Object -Property `
            ProcessId, `
            ParentProcessId, `
            Name, `
            Description, `
            CreationDate, `
            CommandLine, `
            ExecutablePath, `
            WorkingSetSize, `
            VirtualSize, `
            PageFaults, `
            PageFileUsage, `
            Priority, `
            ThreadCount, `
            HandleCount
    }
    catch {
        Write-Error "Error getting platform process info. Details: $($_.Exception.Message)"
        exit(1)
    }

    $Processes
}
