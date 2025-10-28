function Install-SystCompletions {
    <#
    .SYNOPSIS
        Installs PowerShell completions for the syst Go application.
    
    .DESCRIPTION
        Downloads completions from 'syst completion' command and installs them to a PowerShell module path.
        If completions already exist, they will be overwritten.
    
    .PARAMETER CompletionsPath
        Optional custom path to install completions. If not specified, uses the user's PowerShell modules directory.
    
    .PARAMETER Force
        Force installation even if syst command is not found.
    
    .EXAMPLE
        Install-SystCompletions
        Installs syst completions to the default location.
    
    .EXAMPLE
        Install-SystCompletions -CompletionsPath "C:\MyCompletions"
        Installs syst completions to a custom directory.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$CompletionsPath,
        
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    
    # Determine installation path
    if (-not $CompletionsPath) {
        $userModulesPath = [Environment]::GetFolderPath('MyDocuments')
        $CompletionsPath = Join-Path -Path $userModulesPath -ChildPath "PowerShell\Completions"
    }
    
    # Create completions directory if it doesn't exist
    if (-not (Test-Path -Path $CompletionsPath)) {
        try {
            New-Item -Path $CompletionsPath -ItemType Directory -Force | Out-Null
            Write-Verbose "Created completions directory: $CompletionsPath"
        }
        catch {
            Write-Error "Failed to create completions directory: $($_.Exception.Message)"
            return
        }
    }
    
    # Check if syst command exists
    $systCommand = Get-Command "syst" -ErrorAction SilentlyContinue
    if (-not $systCommand -and -not $Force) {
        Write-Warning "syst command not found in PATH. Use -Force to bypass this check."
        return
    }
    
    $completionsFile = Join-Path -Path $CompletionsPath -ChildPath "syst-completions.ps1"
    
    try {
        Write-Host "Generating syst completions..." -ForegroundColor Cyan
        
        # Get completions from syst
        $completionsContent = & syst completion powershell 2>$null
        
        if (-not $completionsContent) {
            Write-Warning "No completions received from 'syst completion powershell' command"
            return
        }
        
        # Write completions to file (no validation - just install whatever we get)
        $completionsContent | Set-Content -Path $completionsFile -Encoding UTF8 -Force
        
        Write-Host "Syst completions installed to: $completionsFile" -ForegroundColor Green
        
        # Add to PowerShell profile if not already present
        $profilePath = $PROFILE
        if (Test-Path -Path $profilePath) {
            $profileContent = Get-Content -Path $profilePath -Raw
            $importLine = ". `"$completionsFile`""
            
            if ($profileContent -notmatch [regex]::Escape($completionsFile)) {
                Write-Host "Adding completions import to PowerShell profile..." -ForegroundColor Cyan
                Add-Content -Path $profilePath -Value "`n# Syst completions`n$importLine" -Encoding UTF8
                Write-Host "Completions import added to profile. Restart PowerShell or run: . `"$completionsFile`"" -ForegroundColor Green
            }
            else {
                Write-Host "Completions import already exists in profile" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "PowerShell profile not found. Manually source completions with: . `"$completionsFile`"" -ForegroundColor Yellow
        }
        
    }
    catch {
        Write-Error "Failed to install syst completions: $($_.Exception.Message)"
    }
}
