function unzip {
    param(
        [string]$file
    )
    $dirname = (Get-Item $file).BaseName

    Write-Output ("Extracting", $file, "to", $dirname)

    New-Item -Force -ItemType directory -Path $dirname
    Expand-Archive $file -OutputPath $dirname -ShowProgress
}
