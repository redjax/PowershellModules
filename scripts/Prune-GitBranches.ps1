<#
    .SYNOPSIS
    Clean up local branches that have been deleted on the remote

    .DESCRIPTION
        This script checks out the main branch, fetches from the remote, then
        deletes (prunes) any local branches that still exist after being deleted
        on the remote.

        WARNING: This is a destructive script. Make sure you don't need the local
        copy of your branch before pruning.
    
    .PARAMETER MainBranch
        The name of the main branch.

    .EXAMPLE
        .\scripts\Prune-GitBranches.ps1
#>
param(
    [String]$MainBranch = "main"
)

Write-Host "Pruning local branches that have been deleted on the remote." -ForegroundColor Green

try {
    git checkout $($MainBranch); `
        git remote update origin --prune; `
        git branch -vv `
    | Select-String -Pattern ": gone]" `
    | ForEach-Object {
        $_.toString().Trim().Split(" ")[0]
    } `
    | ForEach-Object {
        git branch -d $_ 
    }

    Write-Host "Local branches pruned." -ForegroundColor Green

    exit 0
}
catch {
    Write-Warning "Error pruning local branches. Details: $($_.Exception.Message)"
    exit 1
}