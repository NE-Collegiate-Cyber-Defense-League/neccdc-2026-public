#Requires -Modules ActiveDirectory

[CmdletBinding()]
param (
    [String]
    $LockoutThreshold = 120,

    [String]
    $MinLength = 2,

    [String]
    $LockoutDuration = "0:0:0:0.0",

    [String]
    $LockoutObservationWindow = "0:0:0:0.0",

    [Boolean]
    $ComplexityEnabled = $false,

    [Boolean]
    $ReversibleEncryptionEnabled = $true
)

try {
    $RootDSE = Get-ADRootDSE
    $PasswordPolicyParams = @{
        Identity                      = $RootDSE.defaultNamingContext
        AuthType                      = "Negotiate"
        LockoutDuration               = "0:0:0:0.0"
        LockoutObservationWindow      = "0:0:0:0.0"
        LockoutThreshold              = 120
        ComplexityEnabled             = $false
        ReversibleEncryptionEnabled   = $true
        MinPasswordLength             = 2
        MaxPasswordAge                = "10675199.00:00:00"
    }
    
    Set-ADDefaultDomainPasswordPolicy @PasswordPolicyParams    
}
catch {
    $Ansible.Failed = $true
    $Ansible.Message = $_.Exception.Message
}