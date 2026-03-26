# Don't display progress bars
# See: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.3#progresspreference
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

# Check if server core or desktop experience
$InstallationType = Get-ItemProperty -Path "HKLM:/Software/Microsoft/Windows NT/CurrentVersion" | Select-Object -ExpandProperty "InstallationType"

if ($InstallationType -ne "Server Core") {
    Write-Host "Installation type is $InstallationType, skipping Server Core configuration."
    return
}

# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if (-Not $myWindowsPrincipal.IsInRole($adminRole)) {
    Write-Output "ERROR: You need elevated Administrator privileges in order to run this script."
    Write-Output "       Start Windows PowerShell by using the Run as Administrator option."
    Exit 2
}

# Ensure LocalAccountTokenFilterPolicy is set to 1
# https://github.com/ansible/ansible/issues/42978
$token_path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$token_prop_name = "LocalAccountTokenFilterPolicy"
$token_key = Get-Item -Path $token_path
$token_value = $token_key.GetValue($token_prop_name, $null)
if ($token_value -ne 1) {
    Write-Verbose "Setting LocalAccountTOkenFilterPolicy to 1"
    if ($null -ne $token_value) {
        Remove-ItemProperty -Path $token_path -Name $token_prop_name
    }
    New-ItemProperty -Path $token_path -Name $token_prop_name -Value 1 -PropertyType DWORD > $null
}

Write-Host "Installing Server Core Compatibility Tools"

$capabilities = @(
    "ServerCore.AppCompatibility~~~~0.0.1.0",
    "Browser.InternetExplorer~~~~0.0.11.0"
)

foreach ($capability in $capabilities) {

    try {
        Write-Host "Processing: $capability"

        $cap = Get-WindowsCapability -Online -Name $capability -ErrorAction Stop
        $cap | Format-List *

        Add-WindowsCapability -Online -Name $capability -ErrorAction Stop -Verbose

        Write-Host "Successfully installed: $capability"
    }
    catch {
        Write-Host "========================================="
        Write-Host "FAILED installing: $capability"
        Write-Host "Message: $($_.Exception.Message)"
        Write-Host "HResult: $($_.Exception.HResult)"
        Write-Host "StackTrace:"
        Write-Host $_.Exception.StackTrace
        Write-Host "Inner Exception:"
        Write-Host $_.Exception.InnerException
        Write-Host "Full Error Record:"
        $_ | Format-List * -Force
        Write-Host "========================================="

        throw
    }
}