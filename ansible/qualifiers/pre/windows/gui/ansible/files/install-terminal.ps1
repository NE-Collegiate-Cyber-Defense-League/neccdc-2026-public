# Provide URL to newest version of Windows Terminal Application
$url = 'https://github.com/microsoft/terminal/releases/download/v1.16.10261.0/Microsoft.WindowsTerminal_Win10_1.16.10261.0_8wekyb3d8bbwe.msixbundle'
$split = Split-Path $url -Leaf
 
# Prerequisites
Start-BitsTransfer -Source 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' `
-Destination $home\Microsoft.VCLibs.x86.14.00.Desktop.appx
Add-AppxPackage $home\Microsoft.VCLibs.x86.14.00.Desktop.appx
 
# Download
Start-BitsTransfer `
-Source $url `
-Destination (Join-Path -Path $home -ChildPath $split)
 
# Installation
Add-AppxPackage -Path (Join-Path -Path $home -ChildPath $split)