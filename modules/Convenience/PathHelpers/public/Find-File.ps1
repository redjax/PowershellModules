function Find-File {
    param(
        [string]$Name
    )

    Get-ChildItem `
         -Recurse `
         -Filter "*${Name}*" `
         -ErrorAction SilentlyContinue `
         | ForEach-Object {
        $place_path = $_.Directory
        Write-Output "${place_path}\${_}"
    }
}