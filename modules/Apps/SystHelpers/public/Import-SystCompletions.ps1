function Import-SystCompletions {
    <#
    .SYNOPSIS
        Imports syst completions if they are installed.
    
    .DESCRIPTION
        Looks for installed syst completions and imports them into the current session.
        This is useful for loading completions without reinstalling them.
    
    .PARAMETER CompletionsPath
        Optional custom path where completions are installed.
    
    .EXAMPLE
        Import-SystCompletions
        Imports syst completions from the default location.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$CompletionsPath
    )
    
    # Determine completions path
    if (-not $CompletionsPath) {
        $userModulesPath = [Environment]::GetFolderPath('MyDocuments')
        $CompletionsPath = Join-Path -Path $userModulesPath -ChildPath "PowerShell\Completions"
    }
    
    $completionsFile = Join-Path -Path $CompletionsPath -ChildPath "syst-completions.ps1"
    
    if (Test-Path -Path $completionsFile) {
        try {
            . $completionsFile
            Write-Verbose "Syst completions loaded from: $completionsFile"
        }
        catch {
            Write-Warning "Failed to load syst completions: $($_.Exception.Message)"
        }
    }
    else {
        Write-Verbose "Syst completions not found at: $completionsFile"
        Write-Host "Run 'Install-SystCompletions' to install completions first" -ForegroundColor Yellow
    }
}
