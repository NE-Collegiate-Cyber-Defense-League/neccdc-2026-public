param(
  [string]$MysqlExe = "C:\\xampp\\mysql\\bin\\mysql.exe",
  [string]$RootUser = "root",
  [string]$MysqlUsername = "Administrator",
  [string]$MysqlPassword = "Admin@1231"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $MysqlExe)) { throw "mysql.exe not found at: $MysqlExe" }

# Escape for SQL single-quoted literals
$u = ([string]$MysqlUsername).Replace("'", "''")
$p = ([string]$MysqlPassword).Replace("'", "''")

# Determine if user existed beforehand (for Changed)
$userCount = & $MysqlExe "-u$RootUser" -N -s -e "SELECT COUNT(*) FROM mysql.user WHERE User='$u' AND Host='%';"
if ($LASTEXITCODE -ne 0) { throw "mysql user check failed (exit $LASTEXITCODE)" }
$userExists = ((($userCount | Out-String).Trim() -as [int]) -gt 0)

# Create user if missing, always enforce password, grant all
& $MysqlExe "-u$RootUser" -e "CREATE USER IF NOT EXISTS '$u'@'%' IDENTIFIED BY '$p';"
if ($LASTEXITCODE -ne 0) { throw "mysql create user failed (exit $LASTEXITCODE)" }

& $MysqlExe "-u$RootUser" -e "ALTER USER '$u'@'%' IDENTIFIED BY '$p';"
if ($LASTEXITCODE -ne 0) { throw "mysql alter user failed (exit $LASTEXITCODE)" }

& $MysqlExe "-u$RootUser" -e "GRANT ALL PRIVILEGES ON *.* TO '$u'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"
if ($LASTEXITCODE -ne 0) { throw "mysql grant failed (exit $LASTEXITCODE)" }

if ($null -ne $Ansible) {
  $Ansible.Changed = (-not $userExists)
  $Ansible.Result = @{
    user_exists_before = $userExists
    created_user       = (-not $userExists)
    altered_password   = $true
    granted_all        = $true
    user              = "$MysqlUsername@%"
  }
}
