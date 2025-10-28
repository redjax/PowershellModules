function sed {
    param(
        [string]$file,
        [string]$find,
        [string]$replace
    )
    (Get-Content $file).Replace("$find", $replace) | Set-Content $file
    # [System.IO.File]::ReadAllText("$($file)").Replace("$find", "$replace") | Set-Content $file
}
