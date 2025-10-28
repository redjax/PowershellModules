function Start-SystUpgrade {
    if ($p = (Get-Command -Name syst -ErrorAction SilentlyContinue)) {
        Remove-Item $p.Path
    }; & ([scriptblock]::Create(
        (Invoke-RestMethod https://raw.githubusercontent.com/redjax/syst/refs/heads/main/scripts/install-syst.ps1)
    )) -Auto
}
