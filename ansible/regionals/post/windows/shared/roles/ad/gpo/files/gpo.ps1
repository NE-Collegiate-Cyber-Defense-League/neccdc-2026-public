[CmdletBinding()]
param (
    [string]$GPOPath = "C:\temp\gpo\",
    $MappingsJson
)

Import-Module GroupPolicy
Import-Module ActiveDirectory

$Domain = Get-ADDomain | Select-Object -ExpandProperty DNSRoot
$DomainDN = Get-ADDomain | Select-Object -ExpandProperty DistinguishedName

Write-Output "[+] GPO Import and Link Script"
Write-Output "[+] Domain: $Domain"
Write-Output "[+] GPO Source Path: $GPOPath"

foreach ($mapping in $MappingsJson.GetEnumerator()) {
    $BackupPath = Join-Path -Path $GPOPath -ChildPath $mapping.Key
    $ManifestPath = Join-Path -Path $BackupPath -ChildPath "manifest.xml"
    
    if (-Not (Test-Path -Path $ManifestPath)) {
        Write-Output "[!] Manifest file not found for $($mapping.Key), skipping..."
        continue
    }

    [xml]$xml = Get-Content -Path $ManifestPath
    $BackupName = $xml.Backups.BackupInst.GPODisplayName.'#cdata-section'
    $BackupID = $xml.Backups.BackupInst.ID.'#cdata-section' -replace '[{}]'

    Write-Output "[+] Found GPO $BackupName with ID $BackupID for mapping $($mapping.Value)"
    try {
        Import-GPO -BackupId $BackupID -Path $BackupPath -TargetName $mapping.Value -CreateIfNeeded | Out-Null
        New-GPLink -Name $mapping.Value -Target $DomainDN | Out-Null
        Write-Output "[+] Successfully imported and linked GPO $($mapping.Value)"
    }
    catch {
        if ($_.Exception.Message -match "already linked to a Scope of Management with Path") {
            continue
        } else {
            Write-Output "[!] Error processing GPO $($mapping.Value): $_"
            $Ansible.Failed = $true
        }
    }
}

Write-Output "[+] All GPOs processed successfully"
