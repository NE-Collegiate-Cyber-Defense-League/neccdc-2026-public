param(
    [Parameter(Mandatory = $true)]
    [string]$GroupsJson
)

# Convert JSON to PowerShell object
$groups = $GroupsJson | ConvertFrom-Json

# Set manager for each group
foreach ($groupName in $groups.PSObject.Properties.Name) {
    $groupData = $groups.$groupName

    # Skip if manager is not defined
    if (-not $groupData.manager) {
        continue
    }

    try {
        # Resolve manager user (sAMAccountName, DN, UPN, etc.)
        $manager = Get-ADUser -Identity $groupData.manager

        # Set group manager (ManagedBy)
        Set-ADGroup -Identity $groupName -ManagedBy $manager.DistinguishedName
        Write-Host "Set manager for group: $groupName" -ForegroundColor Green
    }
    catch {
        throw "Failed to set manager for group $groupName : $_"
    }
}

Write-Host "Group manager attributes processed successfully" -ForegroundColor Green
