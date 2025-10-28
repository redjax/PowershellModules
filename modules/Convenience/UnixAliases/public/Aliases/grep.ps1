function grep {
    param(
        [string]$regex,
        [string]$dir
    )
    if ($dir) {
        Get-ChildItem $dir | Select-String $regex
        return
    }
    $input | Select-String $regex
}
