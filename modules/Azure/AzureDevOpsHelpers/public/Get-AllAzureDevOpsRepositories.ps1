function Get-AllAzureDevOpsRepositories {
    <#
    .SYNOPSIS
        Retrieves all repositories from all projects in an Azure DevOps organization and exports them to a CSV file.

    .DESCRIPTION
        This function iterates through all projects in an Azure DevOps organization, retrieves all repositories 
        within each project, and exports the combined data to a CSV file. The output includes both project 
        and repository information for comprehensive reporting.

    .PARAMETER Organization
        The Azure DevOps organization name (e.g., 'myorganization' from https://dev.azure.com/myorganization/).

    .PARAMETER OutputPath
        The full path where the CSV file will be saved. If not specified, defaults to 'AzureDevOps_AllRepositories.csv' 
        in the current directory.

    .PARAMETER PersonalAccessToken
        The Personal Access Token (PAT) for Azure DevOps API authentication. Must have appropriate permissions 
        to read projects and repositories.

    .PARAMETER PersonalAccessTokenFile
        Alternative to PersonalAccessToken. Path to a file containing the PAT. The file should contain only the token.

    .EXAMPLE
        Get-AllAzureDevOpsRepositories -Organization "myorg" -PersonalAccessToken "abc123..." -OutputPath "C:\temp\repos.csv"
        
        Retrieves all repositories from all projects in 'myorg' and saves to the specified CSV file.

    .EXAMPLE
        Get-AllAzureDevOpsRepositories -Organization "myorg" -PersonalAccessTokenFile "C:\secure\pat.txt"
        
        Uses a PAT from a file and saves output to the default CSV file in the current directory.

    .NOTES
        Requires the following functions to be available:
        - Get-AzureDevOpsProjects
        - Get-AzureDevOpsProjectRepositories
        - Invoke-AzureDevOpsApi (private function)
        
        The PAT must have the following permissions:
        - Project and Team (Read)
        - Code (Read)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Azure DevOps organization name")]
        [string]$Organization,
        
        [Parameter(Mandatory = $false, HelpMessage = "Output CSV file path")]
        [string]$OutputPath = "AzureDevOps_AllRepositories.csv",
        
        [Parameter(Mandatory = $false, ParameterSetName = "Token", HelpMessage = "Personal Access Token")]
        [string]$PersonalAccessToken,
        
        [Parameter(Mandatory = $false, ParameterSetName = "TokenFile", HelpMessage = "Path to file containing PAT")]
        [string]$PersonalAccessTokenFile
    )

    ## Validate that either PersonalAccessToken or PersonalAccessTokenFile is provided
    if ([string]::IsNullOrWhiteSpace($PersonalAccessToken) -and [string]::IsNullOrWhiteSpace($PersonalAccessTokenFile)) {
        Write-Error "Either PersonalAccessToken or PersonalAccessTokenFile must be provided"
        return
    }

    ## Main execution
    try {
        ## Validate output directory exists
        $OutputDirectory = Split-Path -Path $OutputPath -Parent
        if (-not [string]::IsNullOrWhiteSpace($OutputDirectory) -and -not (Test-Path -Path $OutputDirectory)) {
            Write-Error "Output directory does not exist: $OutputDirectory"
            return
        }

        Write-Host "Starting Azure DevOps data extraction..." -ForegroundColor Cyan
        Write-Host "Organization: $Organization" -ForegroundColor Cyan
        Write-Host "Output file: $OutputPath" -ForegroundColor Cyan
        Write-Host ""
    
        ## Determine which PAT to use
        $Pat = $null
        if (-not [string]::IsNullOrWhiteSpace($PersonalAccessToken)) {
            $Pat = $PersonalAccessToken
            Write-Host "Using PAT from parameter" -ForegroundColor Gray
        }
        elseif (-not [string]::IsNullOrWhiteSpace($PersonalAccessTokenFile)) {
            if (Test-Path $PersonalAccessTokenFile) {
                try {
                    $Pat = (Get-Content $PersonalAccessTokenFile -Raw).Trim()
                    if ([string]::IsNullOrWhiteSpace($Pat)) {
                        Write-Error "PAT file exists but is empty: $PersonalAccessTokenFile"
                        exit 1
                    }
                    Write-Host "Using PAT from file: $PersonalAccessTokenFile" -ForegroundColor Gray
                }
                catch {
                    Write-Error "Failed to read PAT from file '$PersonalAccessTokenFile': $_"
                    exit 1
                }
            }
            else {
                Write-Error "PAT file not found: $PersonalAccessTokenFile"
                exit 1
            }
        }
        else {
            Write-Error "Either PersonalAccessToken or PersonalAccessTokenFile must be provided"
            exit 1
        }
    
        ## Get all projects
        $projects = Get-AzureDevOpsProjects -Organization $Organization -Pat $Pat
    
        if ($projects.Count -eq 0) {
            Write-Error "No projects found. Please check your organization name and PAT permissions."
            exit 1
        }
    
        ## Collection to store all data
        $allData = @()
    
        ## Process each project
        foreach ($project in $projects) {
            Write-Host "Processing project: $($project.name)" -ForegroundColor Yellow
        
            ## Get repositories for this project
            $repositories = Get-AzureDevOpsProjectRepositories -Organization $Organization -ProjectId $project.id -Pat $Pat
        
            if ($repositories.Count -eq 0) {
                ## If no repositories, still add project info
                $projectData = [PSCustomObject]@{
                    ProjectId               = $project.id
                    ProjectName             = $project.name
                    ProjectDescription      = $project.description
                    ProjectUrl              = $project.url
                    ProjectState            = $project.state
                    ProjectVisibility       = $project.visibility
                    ProjectLastUpdateTime   = $project.lastUpdateTime
                    RepositoryId            = ""
                    RepositoryName          = ""
                    RepositoryUrl           = ""
                    RepositoryDefaultBranch = ""
                    RepositorySize          = ""
                    RepositoryIsDisabled    = ""
                    RepositoryRemoteUrl     = ""
                }
                $allData += $projectData
            }
            else {
                ## Add each repository with project info
                foreach ($repo in $repositories) {
                    $projectData = [PSCustomObject]@{
                        ProjectId               = $project.id
                        ProjectName             = $project.name
                        ProjectDescription      = $project.description
                        ProjectUrl              = $project.url
                        ProjectState            = $project.state
                        ProjectVisibility       = $project.visibility
                        ProjectLastUpdateTime   = $project.lastUpdateTime
                        RepositoryId            = $repo.id
                        RepositoryName          = $repo.name
                        RepositoryUrl           = $repo.url
                        RepositoryDefaultBranch = $repo.defaultBranch
                        RepositorySize          = $repo.size
                        RepositoryIsDisabled    = $repo.isDisabled
                        RepositoryRemoteUrl     = $repo.remoteUrl
                    }
                    $allData += $projectData
                }
            }
        
            Write-Host "  - Found $($repositories.Count) repositories" -ForegroundColor Gray
        }
    
        ## Export to CSV
        Write-Host ""
        Write-Host "Exporting data to CSV..." -ForegroundColor Green

        try {
            $allData | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
            Write-Host "Export completed successfully!" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to export data to CSV: $_"
            return
        }

        ## Display summary information
        $repoCount = ($allData | Where-Object { $_.RepositoryId -ne '' }).Count
        $projectsWithRepos = ($allData | Where-Object { $_.RepositoryId -ne '' } | Group-Object ProjectName).Count
        
        Write-Host ""
        Write-Host "=== SUMMARY ===" -ForegroundColor Green
        Write-Host "Total projects: $($projects.Count)" -ForegroundColor Cyan
        Write-Host "Projects with repositories: $projectsWithRepos" -ForegroundColor Cyan
        Write-Host "Total repositories: $repoCount" -ForegroundColor Cyan
        Write-Host "Output file: $OutputPath" -ForegroundColor Cyan
        
        if (Test-Path $OutputPath) {
            Write-Host "File size: $([Math]::Round((Get-Item $OutputPath).Length / 1KB, 2)) KB" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Error "An error occurred during execution: $_"
        Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
        return
    }
}