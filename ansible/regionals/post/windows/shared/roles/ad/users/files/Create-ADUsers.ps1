#Requires -Modules ActiveDirectory

param(
    [Parameter(Mandatory = $true)]
    [string]$UsersJson
)

# Convert JSON to PowerShell object
$users = $UsersJson | ConvertFrom-Json

$Domain = Get-ADDomain | Select-Object -ExpandProperty DNSRoot
$NetBIOS = Get-ADDomain | Select-Object -ExpandProperty NetBIOSName


foreach ($userName in $users.PSObject.Properties.Name) {
    $userData = $users.$userName

    $params = @{
        AccountPassword = ConvertTo-SecureString -String $userData.password -AsPlainText -Force
        GivenName       = $userData.firstname
        Surname         = $userData.surname
        Name            = "$($userData.firstname) $($userData.surname)"
        DisplayName     = "$($userData.firstname) $($userData.surname)"
        SamAccountName  = $userName
        Path            = $userData.path
        Enabled         = $true
        Company         = $NetBIOS
    }

    if ($userData.upn) {
        $params["UserPrincipalName"] = $userData.upn
        $params["EmailAddress"] = $userData.upn
    } else {
        $params["UserPrincipalName"] = "$userName@$Domain"
        $params["EmailAddress"] = "$userName@$Domain"
    }
    # Overrides email if provided, otherwise defaults to UPN or samAccountName@domain
    if ($userData.email) {
        $params["EmailAddress"] = $userData.email
    }
    if ($userData.employee_id) {
        $params["EmployeeID"] = $userData.employee_id
    }
    if ($userData.position) {
        $params["Title"] = $userData.position
    }
    if ($userData.department) {
        $params["Department"] = $userData.department
    }
    if ($userData.department -and $userData.position) {
        $params["Description"] = "$($userData.department) - $($userData.position)"
    }

    # Custom attributes
    if ($userData.totp_secret) {
        $params["OtherAttributes"] = @{"msDS-cloudExtensionAttribute1" = $userData.totp_secret}
    }

    $existingUser = Get-ADUser -Filter { SamAccountName -eq $userName } -ErrorAction SilentlyContinue
    if ($null -eq $existingUser) {
        New-ADUser @params
        Write-Output "[+] Created user '$userName'"
    } else {
        Write-Output "[+] User '$userName' already exists"
        # remove account password from params for Set-ADUser since it cannot be updated with Set-ADUser
        $params.Remove("AccountPassword") | Out-Null
        $params.Remove("Name") | Out-Null
        $params.Remove("Path") | Out-Null
        $params.Remove("OtherAttributes") | Out-Null
        Set-ADUser @params -Identity $existingUser
    }

    if ($userData.groups -and $userData.groups.Count -gt 0) {
        foreach ($group in $userData.groups) {
            Add-ADGroupMember -Identity $group -Members $userName -ErrorAction SilentlyContinue
        }
    }
}