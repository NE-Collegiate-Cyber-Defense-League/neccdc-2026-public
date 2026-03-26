param(
  [string]$MysqlExe = "C:\\xampp\\mysql\\bin\\mysql.exe",
  [string]$RootUser = "root",
  [string]$Database = "ospos",
  [string]$SqlFile  = "C:\\xampp\\htdocs\\ospos\\app\\Database\\ospos_export.sql"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $MysqlExe)) { throw "mysql.exe not found at: $MysqlExe" }
if (-not (Test-Path -LiteralPath $SqlFile))  { throw "SQL file not found at: $SqlFile" }

# Drop + recreate DB (identifier quoted with MySQL backticks)
& $MysqlExe "-u$RootUser" -e "DROP DATABASE IF EXISTS ``$Database``; CREATE DATABASE ``$Database``;"
if ($LASTEXITCODE -ne 0) { throw "mysql drop/create failed (exit $LASTEXITCODE)" }

# Import schema (PowerShell-safe, no '<' redirection)
Get-Content -LiteralPath $SqlFile -Raw | & $MysqlExe "-u$RootUser" $Database
if ($LASTEXITCODE -ne 0) { throw "mysql import failed (exit $LASTEXITCODE)" }

if ($null -ne $Ansible) {
  $Ansible.Changed = $true
  $Ansible.Result = @{
    database = $Database
    sql_file = $SqlFile
    rebuilt  = $true
    imported = $true
  }
}
