param(
    [Parameter(Mandatory = $true)]
    [string]$GroupsJson
)

# Convert JSON to PowerShell object
$groups = $GroupsJson | ConvertFrom-Json

# Create each group
foreach ($groupName in $groups.PSObject.Properties.Name) {
    $groupData = $groups.$groupName
    
    try {
        # Check if group already exists
        $existingGroup = Get-ADGroup -Filter { Name -eq $groupName } -ErrorAction SilentlyContinue
        
        if ($null -eq $existingGroup) {
            # Create new group
            $newGroupParams = @{
                Name        = $groupName
                GroupScope  = "Global"
                GroupCategory = "Security"
            }
            
            if ($groupData.path) {
                $newGroupParams["Path"] = $groupData.path
            }

            if ($groupData.description) {
                $newGroupParams["Description"] = $groupData.description
            }
            
            New-ADGroup @newGroupParams
            Write-Host "Created group: $groupName" -ForegroundColor Green
        }
        else {
            # Update existing group if description is provided
            if ($groupData.description) {
                Set-ADGroup -Identity $groupName -Description $groupData.description
            }
            Write-Host "Group already exists: $groupName" -ForegroundColor Yellow
        }
        
        # Add group to other groups if memberOf is specified
        if ($groupData.memberOf) {
            foreach ($parentGroup in $groupData.memberOf) {
                try {
                    # Check if the group is already a member
                    $members = Get-ADGroupMember -Identity $parentGroup -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $groupName }
                    
                    if ($null -eq $members) {
                        Add-ADGroupMember -Identity $parentGroup -Members $groupName
                        Write-Host "  Added $groupName to group: $parentGroup" -ForegroundColor Cyan
                    }
                    else {
                        Write-Host "  $groupName already member of: $parentGroup" -ForegroundColor DarkGray
                    }
                }
                catch {
                    Write-Warning "Failed to add $groupName to group $parentGroup : $_"
                }
            }
        }
    }
    catch {
        throw "Failed to create/update group $groupName : $_"
    }
}

Write-Host "All groups processed successfully" -ForegroundColor Green
