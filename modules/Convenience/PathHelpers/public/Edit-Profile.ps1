function Edit-Profile {
    <#
        Open current profile.ps1 in PowerShell ISE
    #>
    param(
        [string]$Editor = "notepad"
    )
    $ProfilePath = $($PROFILE)
    Write-Debug "Editor: $Editor, Profile: $($ProfilePath)"

    if ($host.Name -match 'ise') {
        ## Edit in PowerShell ISE, if available
        $psISE.CurrentPowerShellTab.Files.Add($ProfilePath)
    }
    else {
        ## Edit in Notepad if no PowerShell ISE found
        & $Editor $ProfilePath
    }
}