#Requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [switch] $CreateUsers,
    [switch] $CreateGroups,

    # Optional override; if omitted we pull from AD
    [string] $Domain,

    # Optional override
    [string] $CsvPath = "C:\users.csv"
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# Config
# ------------------------------------------------------------

# CSV -> AD field mapping (AD field = CSV header)
$UserFieldMap = @{
    GivenName      = 'first_name'
    Surname        = 'last_name'
    SamAccountName = 'username'
    Department     = 'department'
    Title          = 'position'
    Password       = 'password'
}

# Role -> Group mapping (GroupName = Title regex), intentionally broad
$RoleMapping = @{
    "Enterprise Admins"           = "CEO|CISO|CFO|COO|System Admin"
    "Domain Admins"               = "CEO|CISO|CFO|COO|System Admin|System Engineering|Network Technician"
    "Group Policy Creator Owners" = "System Admin|System Engineering|Network Technician|Help Desk|Repair Technician"
    "Schema Admins"               = "CISO|CFO|System Admin|System Engineering"
}

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

function Assert-CsvHasColumns {
    param(
        [Parameter(Mandatory)] $Data,
        [Parameter(Mandatory)] [hashtable] $FieldMap
    )

    if (-not $Data -or $Data.Count -eq 0) {
        throw "CSV '$CsvPath' contained no rows."
    }

    $headers = $Data[0].PSObject.Properties.Name
    foreach ($col in $FieldMap.Values) {
        if ($col -notin $headers) {
            throw "CSV is missing required column '$col' (defined in UserFieldMap)"
        }
    }
}

function Ensure-Group {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Description
    )

    try {
        Get-ADGroup -Identity $Name -ErrorAction Stop | Out-Null
        Write-Output "[+] Group '$Name' already exists"
    } catch {
        New-ADGroup -Name $Name -GroupCategory Security -GroupScope Global -Description $Description -Path $Path
        Write-Output "[+] Created group '$Name'"
    }
}

# ------------------------------------------------------------
# Context
# ------------------------------------------------------------

if (-not (Test-Path -LiteralPath $CsvPath)) {
    throw "CSV not found: $CsvPath"
}

$Data = Import-Csv -LiteralPath $CsvPath
Assert-CsvHasColumns -Data $Data -FieldMap $UserFieldMap

$adDomain = Get-ADDomain
if (-not $Domain -or -not $Domain.Trim()) {
    $Domain = $adDomain.DNSRoot
}
$DomainDN = $adDomain.DistinguishedName

$UsersOUPath  = "CN=Users,$DomainDN"
$GroupsOUPath = "CN=Users,$DomainDN"

# ------------------------------------------------------------
# Password policy (intentionally weak for competition)
# ------------------------------------------------------------

$RootDSE = Get-ADRootDSE
$PasswordPolicyParams = @{
    Identity                    = $RootDSE.defaultNamingContext
    AuthType                    = "Negotiate"
    LockoutDuration             = "0:0:0:0.0"
    LockoutObservationWindow    = "0:0:0:0.0"
    LockoutThreshold            = 120
    ComplexityEnabled           = $false
    ReversibleEncryptionEnabled = $true
    MinPasswordLength           = 2
    MaxPasswordAge              = "10675199.00:00:00"
}

Set-ADDefaultDomainPasswordPolicy @PasswordPolicyParams

# ------------------------------------------------------------
# Users
# ------------------------------------------------------------

if ($CreateUsers) {
    Write-Output "[+] Creating bulk users in $Domain"

    foreach ($row in $Data) {
        $username = $row.($UserFieldMap.SamAccountName)
        $password = $row.($UserFieldMap.Password)

        try {
            $given = $row.($UserFieldMap.GivenName)
            $sur   = $row.($UserFieldMap.Surname)
            $full  = "$given $sur"

            $splat = @{
                AccountPassword   = ConvertTo-SecureString -String $password -AsPlainText -Force
                Company           = $Domain
                Department        = $row.($UserFieldMap.Department)
                GivenName         = $given
                Surname           = $sur
                SamAccountName    = $username
                UserPrincipalName = "$username@$Domain"
                Title             = $row.($UserFieldMap.Title)
                Path              = $UsersOUPath
                Enabled           = $true
                Name              = $full
                DisplayName       = $full
            }

            New-ADUser @splat
            Write-Output "[+] Created user '$username'"
        } catch {
            if ($_.Exception.Message -match "already exists") {
                Write-Output "[+] User '$username' already exists"
                continue
            }
            Write-Output "[!] Failed creating '$username': $_"
        }
    }
} else {
    Write-Output "[+] Skipping user creation"
}

# ------------------------------------------------------------
# Groups
# ------------------------------------------------------------

if ($CreateGroups) {
    Write-Output "[+] Creating department groups in $Domain"

    # Department-based groups from CSV (not AD), then populate by AD Department attribute
    $Departments = $Data |
        ForEach-Object { $_.($UserFieldMap.Department) } |
        Where-Object { $_ -and "$_".Trim() } |
        Sort-Object -Unique

    foreach ($dept in $Departments) {
        try {
            Ensure-Group -Name $dept -Path $GroupsOUPath -Description $Domain

            $deptUsers = Get-ADUser -Filter "Department -eq '$dept'"
            if ($deptUsers) {
                Add-ADGroupMember -Identity $dept -Members $deptUsers -ErrorAction SilentlyContinue
                Write-Output "[+] Added users to '$dept'"
            }
        } catch {
            Write-Output "[!] Failed processing department '$dept': $_"
        }
    }

    Write-Output "[+] Adding users to role-mapped admin groups"

    # Ensure role groups exist (some are built-in; safe either way)
    foreach ($g in $RoleMapping.Keys) {
        try {
            Ensure-Group -Name $g -Path $GroupsOUPath -Description "$Domain (competition admin group)"
        } catch {
            Write-Output "[!] Failed ensuring group '$g': $_"
        }
    }

    $AllUsers = Get-ADUser -Filter * -Properties Title

    foreach ($g in $RoleMapping.Keys) {
        try {
            $pattern = [string]$RoleMapping[$g]
            $members = $AllUsers | Where-Object { $_.Title -match $pattern }

            if ($members) {
                Add-ADGroupMember -Identity $g -Members $members -ErrorAction SilentlyContinue
                Write-Output "[+] Added $($members.Count) member(s) to '$g'"
            } else {
                Write-Output "[+] No matches for '$g'"
            }
        } catch {
            Write-Output "[!] Failed adding members to '$g': $_"
        }
    }
} else {
    Write-Output "[+] Skipping group creation"
}
