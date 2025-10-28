## Function to make REST API calls to Azure DevOps
function Invoke-AzureDevOpsApi {
    param(
        [string]$Uri,
        [string]$Pat
    )
    
    try {
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
        $headers = @{
            Authorization = "Basic $base64AuthInfo"
            'Content-Type' = 'application/json'
        }
        
        $response = Invoke-RestMethod -Uri $Uri -Headers $headers -Method Get
        return $response
    }
    catch {
        Write-Error "Failed to call API: $Uri. Error: $_"
        return $null
    }
}