function Get-PlatformUsers {
    <#
        .SYNOPSIS
        Return user account information.
    #>
    try {
        $UserAccounts = Get-WmiObject Win32_UserAccount | Select-Object -Property `
            Domain, `
            Name, `
            Description, `
            LocalAccount, `
            Status, `
            Disabled, `
            Lockout, `
            PasswordRequired, `
            PasswordExpires, `
            PasswordChangeable, `
            SID, `
            SIDType, `
            AccountType
    }
    catch {
        Write-Error "Error getting platform user info. Details: $($_.Exception.Message)"
        exit(1)
    }

    $UserAccounts
}
