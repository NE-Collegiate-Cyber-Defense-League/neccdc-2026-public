$SourceRoot = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
$PublicDesktop = [System.Environment]::GetFolderPath("CommonDesktopDirectory")


if (-not (Test-Path $PublicDesktop)) {
    New-Item -ItemType Directory -Path $PublicDesktop | Out-Null
}

# Hardcoded absolute shortcut paths (based on your LayoutModificationTemplate)
$Links = @(
    # Windows Server group
    "$SourceRoot\System Tools\Task Manager.lnk",
    "$SourceRoot\Administrative Tools\Computer Management.lnk",
    "$SourceRoot\Accessories\Remote Desktop Connection.lnk",
    "$SourceRoot\Administrative Tools\Event Viewer.lnk",
    "$SourceRoot\Administrative Tools\Registry Editor.lnk",
    "$SourceRoot\Server Manager.lnk",

    # Tools / browsers group
    "$SourceRoot\WinSCP.lnk",
    "$SourceRoot\Everything.lnk",
    "$SourceRoot\Firefox.lnk",
    "$SourceRoot\Microsoft Edge.lnk",
    "$SourceRoot\System Informer.lnk",
    "$SourceRoot\Wireshark.lnk",
    "$SourceRoot\Visual Studio Code\Visual Studio Code.lnk",
    "$SourceRoot\Google Chrome.lnk",

    # AD / management group
    "$SourceRoot\Administrative Tools\Active Directory Domains and Trusts.lnk",
    "$SourceRoot\Administrative Tools\Group Policy Management.lnk",
    "$SourceRoot\Administrative Tools\Active Directory Administrative Center.lnk",
    "$SourceRoot\Administrative Tools\Certification Authority.lnk",
    "$SourceRoot\Administrative Tools\DNS.LNK",
    "$SourceRoot\Administrative Tools\Active Directory Users and Computers.lnk"
)

foreach ($src in $Links) {
    if (-not (Test-Path $src)) {
        Write-Warning "Missing shortcut: $src"
        continue
    }

    $dest = Join-Path $PublicDesktop (Split-Path $src -Leaf)
    Copy-Item -Path $src -Destination $dest -Force
}

Write-Host "Desktop shortcuts copied to: $PublicDesktop"