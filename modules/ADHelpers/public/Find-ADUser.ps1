function Find-ADUser {
    <#
        .SYNOPSIS
            Search Active Directory for users based on search patterns.
        .DESCRIPTION
            Search for users based on properties like Description, Title, etc.
        .PARAMETER SearchPatterns
            A hashtable of property names and search patterns.
        .PARAMETER Disabled
            Include disabled users in the search.
        .PARAMETER LogicalOperator
            The logical operator ('and'/'or') to use when joining the filter strings.
        .EXAMPLE
            Find-ADUser -SearchPatterns @{ Title = 'Sales' }  # Get all users with 'Sales' anywhere in the title
        .EXAMPLE
            Find-ADUser -SearchPatterns @{ Description = 'Sales'; Title = Sales } -LogicalOperator 'and' # Get all users with 'Sales' anywhere in the description AND title
        .EXAMPLE
            Find-ADUser -SearchPatterns @{ Description = '*developer*'} -Disabled  # Get all disabled users with 'developer' anywhere in the description
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'A hashtable of property names and search patterns.')]
        [ValidateNotNull()]
        [Hashtable]$SearchPatterns,
        [Parameter(Mandatory = $false, HelpMessage = 'When -Disabled is present, also include disabled users in the search.')]
        [switch]$Disabled,
        [Parameter(Mandatory = $false, HelpMessage = 'Logical comparison to use, "and" or "or"')]
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
