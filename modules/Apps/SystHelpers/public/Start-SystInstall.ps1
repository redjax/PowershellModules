function Start-SystInstall {
    if ( $p = (Get-Command -Name syst -ErrorAction SilentlyContinue) ) {
        Write-Warning "syst is already installed at $($p.Path). Use Start-SystUpgrade to upgrade."
        return
    } else {
        & ([scriptblock]::Create((Invoke-RestMethod https://raw.githubusercontent.com/redjax/syst/refs/heads/main/scripts/install-syst.ps1))) -Auto
    }
}