function Search-KVSecret {
    <#
        .SYNOPSIS
        Searches for a secret in an Azure Key Vault and retrieves its value.

        .DESCRIPTION
        This function connects to an Azure Key Vault, searches for a secret by name, and retrieves its value. If an exact match is not found, it lists all secrets that contain the specified name and allows the user to select one to retrieve its value.
        
        The az CLI will use the sign-in user's credentials, and that user must have the necessary permissions to access the Key Vault and its secrets (Key Vault Secrets User or Key Vault Secrets Officer).
        
        .NOTES
        The following Azure permissions are required for the user running this script:
            - Key Vault Secrets User (sufficient for read-only access)
            - Key Vault Secrets Officer (required for read/write access)

        .PARAMETER Vault
        The name of the Azure Key Vault to search in.

        .PARAMETER SecretName
        The name of the secret to search for. If an exact match is not found, it will search for secrets that contain this name.

        .EXAMPLE
        Search-KVSecret -Vault "MyKeyVault" -SecretName "MySecret"
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromRemainingArguments = $false)]
        [string]$Vault,
        [Parameter(Position = 1, Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string]$SecretName
    )

    ## Check if az cli is installed
    if ( -not ( Get-Command az -ErrorAction SilentlyContinue ) ) {
        Write-Error "Azure CLI is not installed or not found in the system PATH." -ForegroundColor Red
        return
    }

    Write-Host "Searching '$Vault' for secret '$SecretName' ..." -ForegroundColor Magenta

    ## Connect to Keyvault and search for secret (case-sensitive exact match first)
    try {
        $Result = az keyvault secret show --vault-name $Vault --name $SecretName --query "value" -o tsv 2>$null
    } catch {
        Write-Error "Error accessing Key Vault: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    ## Check status of last command, retry with case-insensitive search if it failed
    if ( $LASTEXITCODE -eq 0 ) {
        Write-Host $Result -ForegroundColor DarkYellow -NoNewline
        try {
            Set-Clipboard -Value $Result

            Write-Host " - Value copied to clipboard" -ForegroundColor Green
            return
        } catch {
            Write-Error "Failed to copy value to clipboard. Please check your clipboard settings." -ForegroundColor Red
            Write-Host "Secret value: $Result" -ForegroundColor Yellow
            return
        }
    }
    else {
        Write-Host "No exact match found for '$SecretName' - searching case-insensitively..." -ForegroundColor Yellow
    } 

    ## Get all secrets and perform case-insensitive matching
    try {
        $AllSecrets = az keyvault secret list --vault-name $Vault --query "[].name" -o tsv
    } catch {
        Write-Error "Error listing secrets in Key Vault: $($_.Exception.Message)"
        return
    }
    
    if (-not $AllSecrets) {
        Write-Host "No secrets found in vault '$Vault'. Make sure the vault exists and you have proper permissions." -ForegroundColor Red
        return
    }
    
    $AllSecretsList = $AllSecrets -split "`r`n" | Where-Object { $_ -ne "" }
    
    ## First try case-insensitive exact match
    $ExactMatch = $AllSecretsList | Where-Object { $_.ToLower() -eq $SecretName.ToLower() }
    
    if ($ExactMatch) {
        Write-Host "Found case-insensitive exact match: '$ExactMatch'" -ForegroundColor Green
        try {
            $Value = az keyvault secret show --vault-name $Vault --name $ExactMatch --query "value" -o tsv 2>$null
            Write-Host $Value -ForegroundColor DarkYellow -NoNewline
            Set-Clipboard -Value $Value
            Write-Host " - Value copied to clipboard" -ForegroundColor Green
            return
        } catch {
            Write-Error "Failed to retrieve secret value or copy to clipboard." -ForegroundColor Red
            return
        }
    }
    
    ## If no exact match, do partial case-insensitive search
    $PartialMatches = $AllSecretsList | Where-Object { $_.ToLower().Contains($SecretName.ToLower()) }

    if ( $PartialMatches.Count -eq 0 ) {
        Write-Host "No secrets found containing '$SecretName' (case-insensitive search). Make sure the vault '$Vault' exists and you have proper permissions." -ForegroundColor Red
        return
    }
    elseif ($PartialMatches.Count -eq 1) {
        Write-Host "Only one secret found matching - pulling value for '$($PartialMatches[0])' from '$Vault'" -ForegroundColor Green
        $Value = $(az keyvault secret show --vault-name $Vault --name $PartialMatches[0] --query "value" -o tsv 2>$null)
        Write-Host $Value -ForegroundColor DarkYellow -NoNewline
        try {
            Set-Clipboard -Value $Value

            Write-Host " - Value copied to clipboard" -ForegroundColor Green
            return
        } catch {
            Write-Error "Failed to copy value to clipboard. Please check your clipboard settings." -ForegroundColor Red
            Write-Host "Secret value: $Value" -ForegroundColor Yellow
            return
        }
    }

 
    Write-Host "Multiple matching secrets found:"
    for ($i = 0; $i -lt $PartialMatches.Count; $i++) {
        Write-Host "[$i] $($PartialMatches[$i])"
    }

    $Choice = Read-Host "Enter the number of the secret to view its value"
    [int]$ChoiceInt = -1
    if ([int]::TryParse($Choice, [ref]$ChoiceInt) -and $ChoiceInt -ge 0 -and $ChoiceInt -lt $PartialMatches.Count) {
        Write-Host "Pulling value for $($PartialMatches[$ChoiceInt]) from $Vault" -ForegroundColor Green
        $Value = $(az keyvault secret show --vault-name $Vault --name $PartialMatches[$ChoiceInt] --query "value" -o tsv 2>$null)
        Write-Host $Value -ForegroundColor DarkYellow -NoNewline
        Set-Clipboard -Value $Value
        Write-Host " - Value copied to clipboard" -ForegroundColor Green
    }
    else {
        Write-Host "Invalid choice. No secret will be retrieved."
    }
}
