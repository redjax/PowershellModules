function Find-ADUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Hashtable]$SearchPatterns,
        
        [switch]$Disabled,
        [ValidateSet('and', 'or')]
        [string]$LogicalOperator = 'and'
    )

    ## Construct the filter string dynamically
    $filterParts = @()

    ## Filter to only enabled users if -Disabled is not present, otherwise include disabled users
    if ( -not $Disabled ) {
        $filterParts += "(Enabled -eq '$true')"
    }

    ## Build filter string from properties & search patterns passed in -SearchPatterns
    foreach ( $property in $SearchPatterns.Keys ) {
        $pattern = $SearchPatterns[$property]
        $filterParts += "($property -like '*$pattern*')"
    }

    ## Join filter strings into single string
    $filterString = ($filterParts -join " -$LogicalOperator ")

    ## Add required properties (including the correct expiration attribute)
    $allProperties = @($SearchPatterns.Keys) + @(
        'Enabled', 
        'msDS-UserPasswordExpiryTimeComputed', 
        'PasswordNeverExpires',
        'Description'
    )

    Write-Output "Starting AD search..."

    ## Initialize an array to store discovered users
    $discoveredUsers = @()

    ## Search AD
    try {
        $discoveredUsers = Get-ADUser -Filter $filterString -Properties $allProperties | 
        Select-Object SamAccountName, Name, Enabled, Description, @{Name = 'PasswordExpirationDate'; Expression = {
                if ($_.PasswordNeverExpires) { 
                    "Never Expires" 
                }
                else { 
                    [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") 
                }
            }
        }

        Write-Output "Search completed. Found $($discoveredUsers.Count) users."
    }
    catch {
        Write-Error "An error occurred while searching AD: $($_.Exception.Message)"
    }

    ## Return the array of discovered users
    return $discoveredUsers
}
