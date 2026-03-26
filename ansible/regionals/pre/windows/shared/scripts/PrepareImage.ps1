$ErrorActionPreference = 'Stop'

Write-Output "Running Sysprep"
& "$Env:Programfiles\Amazon\EC2Launch\ec2launch.exe" sysprep --shutdown=true