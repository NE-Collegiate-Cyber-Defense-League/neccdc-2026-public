#Requires -Modules ActiveDirectory

param(
    [Parameter(Mandatory = $true)]
    [string]$OUsJson
)

# Convert JSON to PowerShell object
$ous = $OUsJson | ConvertFrom-Json

foreach ($ouName in $ous.PSObject.Properties.Name) {
    $ouData = $ous.$ouName

    $params = @{
        Name = $ouName
        Path = $ouData.path
    }

    if ($ouData.description) {
        $params["Description"] = $ouData.description
    }

    if ($ouData.protect_from_deletion) {
        $params["ProtectedFromAccidentalDeletion"] = $true
    }

    $existingOU = Get-ADOrganizationalUnit -Filter { Name -eq $ouName } -ErrorAction SilentlyContinue
    if ($null -eq $existingOU) {
        New-ADOrganizationalUnit @params
        Write-Output "[+] Created OU '$ouName'"
    } else {
        Write-Output "[+] OU '$ouName' already exists"
    }
}
