function pkill {
    param(
        [string]$name
    )
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
