function Set-KVSecret {
    <#
        .SYNOPSIS
        Sets a secret value in an Azure Key Vault.

        .DESCRIPTION
        This function connects to an Azure Key Vault and sets a secret with the specified value. If the secret already exists, it will be updated with the new value.
        
        The az CLI will use the sign-in user's credentials, and that user must have the necessary permissions to write to the Key Vault (Key Vault Secrets Officer).
        
        .NOTES
        The following Azure permissions are required for the user running this script:
            - Key Vault Secrets Officer (required for read/write access)

        .PARAMETER Vault
        The name of the Azure Key Vault to set the secret in.

        .PARAMETER SecretName
        The name of the secret to set or update.

        .PARAMETER SecretValue
        The value to set for the secret. This will be stored securely in the Key Vault.

        .PARAMETER DryRun
        If specified, shows what would be set without actually performing the operation.

        .EXAMPLE
        Set-KVSecret -Vault "MyKeyVault" -SecretName "MySecret" -SecretValue "MySecretValue"
        
        .EXAMPLE
        Set-KVSecret -Vault "MyKeyVault" -SecretName "MySecret" -SecretValue "MySecretValue" -DryRun
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Vault,
        
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$SecretName,
        
        [Parameter(Position = 2, Mandatory = $true)]
        [string]$SecretValue,
        
        [Parameter(Mandatory = $false)]
        [switch]$DryRun
    )

    ## Check if az cli is installed
    if ( -not ( Get-Command az -ErrorAction SilentlyContinue ) ) {
        Write-Error "Azure CLI is not installed or not found in the system PATH." -ForegroundColor Red
        return
    }

    ## Validate inputs
    if ([string]::IsNullOrWhiteSpace($SecretValue)) {
        Write-Error "SecretValue cannot be empty or whitespace." -ForegroundColor Red
        return
    }

    ## Show what will be done
    Write-Host "Operation Details:" -ForegroundColor Cyan
    Write-Host "  Vault: $Vault" -ForegroundColor White
    Write-Host "  Secret Name: $SecretName" -ForegroundColor White
    Write-Host "  Secret Value: " -ForegroundColor White -NoNewline
    
    ## Mask the secret value for display (show first 5 chars + asterisks)
    if ($SecretValue.Length -gt 5) {
        $maskedValue = $SecretValue.Substring(0, 5) + "*" * ($SecretValue.Length - 5)
    } else {
        $maskedValue = "*" * $SecretValue.Length
    }
    Write-Host $maskedValue -ForegroundColor DarkYellow

    if ($DryRun) {
        Write-Host "`n[DRY RUN] Would set secret '$SecretName' in vault '$Vault' to value (partially masked for security): $maskedValue." -ForegroundColor Yellow
        Write-Host "[DRY RUN] No changes will be made." -ForegroundColor Yellow
        return
    } else {

        ## Confirm the operation
        Write-Host "`nThis will set/update the secret in Azure Key Vault." -ForegroundColor Yellow
        $Confirmation = Read-Host "Do you want to proceed? (y/N)"
        
        if ($Confirmation -ne 'y' -and $Confirmation -ne 'Y') {
            Write-Host "Operation cancelled." -ForegroundColor Red
            return
        }

        ## Set the secret in Key Vault
        Write-Host "`nSetting secret '$SecretName' in vault '$Vault'..." -ForegroundColor Magenta

        try {
            ## Use az keyvault secret set to create or update the secret
            ## Suppress stderr warnings from Azure CLI extensions by redirecting stderr to null
            $Result = az keyvault secret set --vault-name $Vault --name $SecretName --value $SecretValue --query "id" -o tsv 2>$null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Secret '$SecretName' successfully set in vault '$Vault'" -ForegroundColor Green
                
                ## Clean up the result - only show if it looks like a valid URL
                if ($Result -and $Result.StartsWith("https://")) {
                    Write-Host "Secret ID: $Result" -ForegroundColor DarkGray
                }
            } else {
                Write-Error "Failed to set secret. Azure CLI returned exit code $LASTEXITCODE" -ForegroundColor Red
                Write-Host "This could be due to insufficient permissions or the vault not existing." -ForegroundColor Red
            }
        } catch {
            Write-Error "Error setting secret in Key Vault: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }
}
