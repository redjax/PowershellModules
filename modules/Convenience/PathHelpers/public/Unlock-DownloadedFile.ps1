function Unlock-DownloadedFile {
    <#
            .SYNOPSIS
            When downloading a file from the Internet, Windows will
            'lock' the file to prevent execution until you unlock it.
    
            .PARAMETER FilePath
            Path to a file you want to unlock
    
            .EXAMPLE
            Unlock-DownloadedFile -FilePath C:\path\to\file-to-unlock.ext
        #>
        param(
            [string]$FilePath
        )
    
        if (-not $FilePath) {
            Write-Error "Missing a -FilePath to unlock."
            return
        }
    
        Write-Output "Unlocking file: $($FilePath)"
        try {
            Unlock-File -Path "$($FilePath)"
        } catch {
            Write-Error "Unable to unlock file '$($FilePath)'. Details: $($_.Exception.Message)"
            return
        }
    }