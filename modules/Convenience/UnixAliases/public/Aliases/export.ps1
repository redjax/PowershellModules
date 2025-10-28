function export {
    param(
        [string]$name,
        [string]$value
    )
    Set-Item -Force -Path "env:$name" -Value $value;
}
