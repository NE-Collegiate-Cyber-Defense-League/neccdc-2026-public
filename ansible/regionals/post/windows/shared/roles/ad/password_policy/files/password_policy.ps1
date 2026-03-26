[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")] 
#Requires -Modules ActiveDirectory

[CmdletBinding()]
param (
    $LockoutThreshold = 120,
    $MinLength = 2,
    $LockoutDuration = "0:0:0:0.0",
    $LockoutObservationWindow = "0:0:0:0.0",
    $ComplexityEnabled = $false,
    $ReversibleEncryptionEnabled = $true,
    $AuthType = "Negotiate",
    $MaxPasswordAge = "0",
    $MinPasswordAge = "0",
    $PasswordHistoryCount = 0
)

$RootDSE = Get-ADRootDSE
$PasswordPolicyParams = @{
    Identity                    = $RootDSE.defaultNamingContext
    AuthType                    = $AuthType
    LockoutDuration             = $LockoutDuration
    LockoutObservationWindow    = $LockoutObservationWindow
    LockoutThreshold            = $LockoutThreshold
    ComplexityEnabled           = $ComplexityEnabled
    ReversibleEncryptionEnabled = $ReversibleEncryptionEnabled
    MinPasswordLength           = $MinLength
    MaxPasswordAge              = $MaxPasswordAge
    MinPasswordAge              = $MinPasswordAge
    PasswordHistoryCount        = $PasswordHistoryCount
}

Set-ADDefaultDomainPasswordPolicy @PasswordPolicyParams    

