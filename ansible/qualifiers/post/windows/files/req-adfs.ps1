#Requires -Modules ActiveDirectory
#Requires -Modules ADCSTemplate

[CmdletBinding()]
param(
    [string] $TemplateName,
    [string] $ADFSHost
)


# Check for existing ADFS certificate
$existingCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -like "CN=windows-adfs.chefops.local" }

if ($existingCert) {
    Write-Host "ADFS certificate already exists with thumbprint: $($existingCert.Thumbprint)"
} else {
    Write-Host "No existing ADFS certificate found. Requesting new certificate..."
    $params = @{
        Template = 'SSLCertificateTemplate'
        SubjectName = 'CN=windows-adfs.chefops.local'
        DnsName = 'adfs.chefops.local', 'windows-adfs.chefops.local'
        Url = 'ldap:'
        CertStoreLocation = 'Cert:\LocalMachine\My'
    }
    Get-Certificate @params
}