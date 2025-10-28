function pgrep {
    param(
        [string]$name
    )
    Get-Process $name
}
