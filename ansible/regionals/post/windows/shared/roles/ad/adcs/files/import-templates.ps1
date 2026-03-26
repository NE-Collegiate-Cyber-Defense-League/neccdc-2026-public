#Requires -Modules ActiveDirectory
#Requires -Modules ADCSTemplate

# New-ADCSTemplate -DisplayName "SSL Certificate Template" -JSON (Get-Content C:\ssl.json -Raw)

[CmdletBinding()]
param(
    [string] $TemplateName,
    [string] $TemplatePath
)

$ErrorActionPreference = "Stop"

if (-Not (Test-Path $TemplatePath)) {
    throw "Template path '$TemplatePath' does not exist."
}

$CurrentTemplates = Get-ADCSTemplate | Select-Object DisplayName
if ($CurrentTemplates.DisplayName -contains $TemplateName) {
    Write-Warning "Template '$TemplateName' already exists"
    $Ansible.Changed = $false
    return
}

$NetBIOS = (Get-ADDomain).NetBIOSName
$Identities = @("$NetBIOS\Domain Computers")

Get-ADGroupMember -Identity "Domain Controllers" | ForEach-Object {
    $Identities += "$NetBIOS\$($_.SamAccountName)"
}

$params = @{
    DisplayName = $TemplateName
    JSON        = (Get-Content -Path $TemplatePath -Raw)
    Identity    = $Identities
    AutoEnroll  = $true
    Publish     = $true
}

New-ADCSTemplate @params
Write-Host "Template '$TemplateName' has been imported from '$TemplatePath'."
$Ansible.Changed = $true