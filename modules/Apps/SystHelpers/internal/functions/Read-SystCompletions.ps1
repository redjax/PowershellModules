function Read-SystCompletions {
    [CmdletBinding()]
    param()
    
    # Check if completions are already loaded
    if (Get-Command "Complete-Syst" -ErrorAction SilentlyContinue) {
        return
    }
    
    try {
        if (Get-Command "syst" -ErrorAction SilentlyContinue) {
            $completions = syst completion powershell 2>$null
            
            ## Basic validation - check if it looks like PowerShell code
            if ($completions -and $completions -match "Register-ArgumentCompleter|Complete-") {
                Invoke-Expression $completions
                Write-Verbose "Syst completions loaded successfully"
            }
            else {
                Write-Warning "Invalid completion output from syst"
            }
        }
        else {
            Write-Verbose "syst command not found, skipping completion registration"
        }
    }
    catch {
        Write-Warning "Failed to load syst completions: $($_.Exception.Message)"
    }
}
