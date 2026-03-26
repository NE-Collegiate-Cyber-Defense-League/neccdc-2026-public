param(
    [Parameter(Mandatory = $true)]
    [string]$UsersJson
)

# Convert JSON to PowerShell object
$users = $UsersJson | ConvertFrom-Json

# Set manager for each user
foreach ($userName in $users.PSObject.Properties.Name) {
    $userData = $users.$userName
    
    # Skip if manager_dn is not defined
    if (-not $userData.manager) {
        continue
    }

    try {        
        # Get the manager user
        $manager = Get-ADUser -Identity $userData.manager

        # Set the manager
        Set-ADUser -Identity $userName -Manager $manager
        Write-Host "Set manager for user: $userName" -ForegroundColor Green
    }
    catch {
        throw "Failed to set manager for user $userName : $_"
    }
}

Write-Host "Manager attributes processed successfully" -ForegroundColor Green
