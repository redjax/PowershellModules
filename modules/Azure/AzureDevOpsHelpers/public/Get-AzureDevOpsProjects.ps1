## Function to get all projects
function Get-AzureDevOpsProjects {
    param(
        [string]$Organization,
        [string]$Pat
    )
    
    Write-Host "Fetching projects from Azure DevOps organization: $Organization" -ForegroundColor Green
    
    $projectsUri = "https://dev.azure.com/$Organization/_apis/projects?api-version=7.0"
    $projectsResponse = Invoke-AzureDevOpsApi -Uri $projectsUri -Pat $Pat
    
    if ($projectsResponse -and $projectsResponse.value) {
        Write-Host "Found $($projectsResponse.value.Count) projects" -ForegroundColor Yellow
        return $projectsResponse.value
    }
    else {
        Write-Warning "No projects found or failed to retrieve projects"
        return @()
    }
}