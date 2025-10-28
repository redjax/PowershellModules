## Function to get repositories for a specific project
function Get-AzureDevOpsProjectRepositories {
    param(
        [string]$Organization,
        [string]$ProjectId,
        [string]$Pat
    )
    
    $reposUri = "https://dev.azure.com/$Organization/$ProjectId/_apis/git/repositories?api-version=7.0"
    $reposResponse = Invoke-AzureDevOpsApi -Uri $reposUri -Pat $Pat
    
    if ($reposResponse -and $reposResponse.value) {
        return $reposResponse.value
    }
    else {
        return @()
    }
}