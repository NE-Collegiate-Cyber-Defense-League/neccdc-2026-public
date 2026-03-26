# ad/gpo

Imports and links Group Policy Objects into an Active Directory domain. GPO backups are copied to the target DC, imported via `Import-GPO`, and linked at the domain root. After a successful import `gpupdate /force` is run automatically via a handler.

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `gpo_dest_path` | `C:\temp` | Temporary directory on the target where GPO files are staged |
| `gpo_source` | `files/gpo` | Local path to the folder of GPO backup directories to copy |
| `gpo_mappings` | *(required)* | Dictionary mapping backup folder names to target GPO display names |

### `gpo_mappings` format

Keys are subfolder names inside `gpo_source`; values are the GPO names to create/update in AD.

```yaml
gpo_mappings:
  fw_adds: "Firewall - ADDS Rules"
```

## Files Layout

GPO backups exported from a domain must be placed under `files/gpo/` with one subfolder per GPO. Each subfolder must contain a `manifest.xml` (produced by `Backup-GPO`) alongside the GUID-named backup directory:

```
files/gpo/
└── <folder-name>/          # key in gpo_mappings
    ├── manifest.xml
    ├── <GPO-GUID>/
    │   ├── Backup.xml
    │   ├── bkupInfo.xml
    │   ├── gpreport.xml
    │   └── DomainSysvol/
    └── <folder-name>.html  # optional HTML report
```

## Exporting GPOs from an existing domain

Run the following on a domain controller (or any host with the Group Policy module) to export all GPOs into the format expected by this role:

```powershell
$invalidChars = ':\\/' + [RegEx]::Escape(-join [IO.Path]::InvalidPathChars)

$backupDir = 'C:\backup'

Get-GPO -All | ForEach-Object {
  $name = $_.DisplayName -replace "[$invalidChars]", '_'
  $gpoDir = Join-Path $backupDir -ChildPath $name
  New-Item $gpoDir -Type Directory | Out-Null
  Backup-GPO -Guid $_.Id -Path $gpoDir
  Get-GPOReport -Guid $_.Id -ReportType Html -Path "$gpoDir\$name.html"
};
```

Copy the resulting subfolders from `C:\backup\` into `files/gpo/` in this role, then add a corresponding entry for each one to `gpo_mappings`.

## Tasks

1. Creates `gpo_dest_path` on the target host
2. Copies `gpo_source` to the target
3. Runs `gpo.ps1` — imports each GPO from its backup and links it at the domain root; skips GPOs whose manifest is missing, ignores already-linked errors
4. Removes the staging directory
5. Runs `gpupdate /force` via handler if any GPO changed