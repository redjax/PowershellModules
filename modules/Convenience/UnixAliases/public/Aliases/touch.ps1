function touch {
    ## Create a blank file at $file path
    param(
        [string]$file
    )

    '' | Out-File $file -Encoding ASCII
}
