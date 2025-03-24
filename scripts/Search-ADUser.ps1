param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [Hashtable]$SearchPatterns,
        
    [switch]$Disabled,
    [ValidateSet('and', 'or')]
    [string]$LogicalOperator = 'and'
)

try {
    $null = Import-Module .\modules\ADHelpers -ErrorAction Stop
}
catch {
    Write-Error "Error importing ADHelpers module from .\modules\ADHelpers. Details: $($_.Exception.Message)"
}

try {
    $null = Get-Module -Name ADHelpers -ErrorAction Stop
    Write-Debug "ADHelpers module imported successfully."
}
catch {
    Write-Error "ADHelpers module was not imported successfully"
    exit(1)
}

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

try {
    $discoveredUsers = Find-ADUser -SearchPatterns $SearchPatterns -Disabled:($Disabled -eq $true) -LogicalOperator $LogicalOperator

    $discoveredUsers | Format-Table

    Write-Output "Discovered $($discoveredUsers.Count) user(s) matching search criteria"
}
catch {
    Write-Error "An error occurred while searching AD: $($_.Exception.Message)"
}