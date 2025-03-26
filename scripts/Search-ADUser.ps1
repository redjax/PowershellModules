<#
    Calls the Find-ADUser function from the ADHelpers module.

    .PARAMETER SearchPatterns
        A hashtable of properties and search patterns to use when searching AD.

    .PARAMETER Disabled
        Switch to include disabled users in the search.

    .PARAMETER LogicalOperator
        The logical operator to use when combining search patterns.
    
    .EXAMPLE
        .\Search-ADUser.ps1 -SearchPatterns @{Title = "sys*adm*" ; Surname = "Doe"}
#>
param (
    [CmdletBinding()]
    [Parameter(Mandatory = $true, HelpMessage = "A hashtable of properties and search patterns to use when searching AD.")]
    [ValidateNotNull()]
    [Hashtable]$SearchPatterns,
    [Parameter(Mandatory = $false, HelpMessage = "Include disabled users in search results.")]
    [switch]$Disabled,
    [Parameter(Mandatory = $false, HelpMessage = "The logical operator to use when combining search patterns.")]
    [ValidateSet('and', 'or')]
    [string]$LogicalOperator = 'and'
)

## Import the ADHelpers module from the modules directory
try {
    $null = Import-Module .\modules\ActiveDirectory\ADHelpers -ErrorAction Stop
}
catch {
    Write-Error "Error importing ADHelpers module from .\modules\ActiveDirectory\ADHelpers. Details: $($_.Exception.Message)"
    exit(1)
}

## Verify the ADHelpers module was imported
try {
    $null = Get-Module -Name ADHelpers -ErrorAction Stop
    Write-Debug "ADHelpers module imported successfully."
}
catch {
    Write-Error "ADHelpers module was not imported successfully"
    exit(1)
}

## Verify the Find-ADUser command was imported
try {
    $null = Get-Command -Name Find-ADUser -Module ADHelpers -ErrorAction Stop
    Write-Debug "Find-ADUser command imported successfully."
}
catch {
    Write-Error "Find-ADUser command was not imported successfully"
    exit(1)
}

Write-Debug "Searching AD for users matching search patterns:"
foreach ( $Key in $SearchPatterns.Keys ) {
    $Value = $SearchPatterns[$Key]
    Write-Debug "$($Key): $Value"
}

## Search AD for users matching search patterns
try {
    $discoveredUsers = Find-ADUser -SearchPatterns $SearchPatterns -Disabled:($Disabled -eq $true) -LogicalOperator $LogicalOperator

    ## Display the discovered users
    $discoveredUsers | Format-Table

    Write-Output "Discovered $($discoveredUsers.Count) user(s) matching search criteria"

    return $discoveredUsers
}
catch {
    Write-Error "An error occurred while searching AD: $($_.Exception.Message)"
}