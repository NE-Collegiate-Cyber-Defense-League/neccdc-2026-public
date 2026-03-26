# Windows Packer AMI Builds

Packer configuration for building Windows Server 2022 AMIs on AWS for the NECCDC 2026 regionals. Builds are driven by var files so a single set of templates can produce multiple purpose-specific images.

## Structure

```
regionals/pre/windows/
├── build/                          # Packer templates
│   ├── versions.pkr.hcl            # Plugin version constraints
│   ├── variables.pkr.hcl           # Input variable declarations
│   ├── sources.pkr.hcl             # AWS EBS source definition
│   ├── builder.pkr.hcl             # Build/provisioner steps
│   └── vars/                       # Per-build var files
│       ├── core.pkrvars.hcl        # Windows Server Core (headless)
│       ├── gui.pkrvars.hcl         # Windows Server with Desktop Experience
│       ├── pos.pkrvars.hcl         # Point-of-Sale workstation
│       └── keycloak-srv.pkrvars.hcl# Keycloak IAM server
└── shared/                         # Resources shared across all builds
    ├── scripts/                    # PowerShell bootstrap scripts
    ├── templates/                  # EC2Launch / SSM agent templates
    └── ansible/                    # Ansible provisioning
        ├── playbook_core.yaml
        ├── playbook_gui.yaml
        ├── playbook_pos.yaml
        ├── playbook_keycloak.yaml
        ├── vars/common.yaml        # Shared variables (packages, passwords)
        └── roles/                  # Ansible roles
```

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/install) ≥ 1.9
- AWS CLI configured with an `neccdc` profile (`~/.aws/credentials`)
- Ansible installed and available on `$PATH`

Initialize Packer plugins once before building:

```bash
cd build/
packer init .
```

## Building Images

All builds run from the `build/` directory and use `-var-file` to select the target image. AMI names are automatically suffixed with a timestamp.

### Windows Server Core

Minimal headless install. No GUI, RSAT core tools enabled.

```bash
packer build -var-file=vars/core.pkrvars.hcl .
```

**Produces:** `packer-windows-core-<timestamp>`
**Source AMI:** `Windows_Server-2022-English-Core-Base*`
**Playbook:** `playbook_core.yaml`

---

### Windows Server (Desktop Experience / GUI)

Full GUI install with BGInfo, file indexing, and RSAT.

```bash
packer build -var-file=vars/gui.pkrvars.hcl .
```

**Produces:** `packer-windows-gui-<timestamp>`
**Source AMI:** `Windows_Server-2022-English-Full-Base*`
**Playbook:** `playbook_gui.yaml`

---

### Point-of-Sale (POS)

GUI install with XAMPP 8.1 (Apache + MySQL) and Open Source POS pre-configured.

```bash
packer build -var-file=vars/pos.pkrvars.hcl .
```

**Produces:** `packer-windows-pos-<timestamp>`
**Source AMI:** `Windows_Server-2022-English-Full-Base*`
**Playbook:** `playbook_pos.yaml`

---

### Keycloak Server

Server Core install with OpenJDK 21 and Keycloak 26.5.4 configured as a Windows service.

```bash
packer build -var-file=vars/keycloak-srv.pkrvars.hcl .
```

**Produces:** `packer-windows-keycloak-srv-<timestamp>`
**Source AMI:** `Windows_Server-2022-English-Full-Base*`
**Playbook:** `playbook_keycloak.yaml`

---

## Build Comparison

| Var File            | AMI Name                      | GUI | BGInfo | RSAT | XAMPP | Keycloak |
|---------------------|-------------------------------|:---:|:------:|:----:|:-----:|:--------:|
| `core.pkrvars.hcl`  | `packer-windows-core`         |     |        | core |       |          |
| `gui.pkrvars.hcl`   | `packer-windows-gui`          | ✓   | ✓      | ✓    |       |          |
| `pos.pkrvars.hcl`   | `packer-windows-pos`          | ✓   | ✓      | ✓    | ✓     |          |
| `keycloak-srv.pkrvars.hcl` | `packer-windows-keycloak-srv` | | ✓ | ✓  |       | ✓        |

All builds include: Chocolatey packages (git, Python, PowerShell Core, Sysinternals, VSCode, Grafana Alloy), Teleport v16.5.8, PowerShell modules (ADCSTemplate, PSPKI), firewall rules, and the `black-team`/`ssm-user` accounts.

## Overriding Variables

Any variable defined in `variables.pkr.hcl` can be overridden at build time with `-var`:

```bash
# Use a different source AMI
packer build -var-file=vars/gui.pkrvars.hcl \
  -var 'source_ami=Windows_Server-2019-English-Full-Base*' .

# Use a custom administrator password
packer build -var-file=vars/core.pkrvars.hcl \
  -var 'windows_password=MyPassword123!' .

# Override the AMI name
packer build -var-file=vars/pos.pkrvars.hcl \
  -var 'ami_name=my-custom-pos-image' .
```

## Variables Reference

| Variable           | Default                                       | Description |
|--------------------|-----------------------------------------------|-------------|
| `source_ami`       | `Windows_Server-2022-English-Full-Base*`      | AMI name filter for source image |
| `ami_name`         | *(required — set by var file)*                | Base name for the produced AMI |
| `playbook`         | *(required — set by var file)*                | Ansible playbook filename under `shared/ansible/` |
| `windows_username` | `Administrator`                               | WinRM / EC2Launch username |
| `windows_password` | `Admin@1231`                                  | WinRM / EC2Launch password |

## Provisioning Flow

1. **EC2 instance launches** → `bootstrap.pkrtpl.hcl` user-data configures WinRM over HTTP
2. **`ConfigureRemotingForAnsible.ps1`** → creates self-signed cert, configures HTTPS WinRM
3. **Ansible playbook** → installs packages, applies roles, configures the OS
4. **EC2Launch agent config** → written to `C:\ProgramData\Amazon\EC2Launch\config\`
5. **SSM agent config** → written to `C:\Program Files\Amazon\SSM\`
6. **Sysprep** → `ec2launch reset --clean && ec2launch sysprep --shutdown --clean`

## Shared Resources

| Path | Purpose |
|------|---------|
| `shared/scripts/ConfigureRemotingForAnsible.ps1` | WinRM/CredSSP setup for Ansible |
| `shared/scripts/SetupSSH.ps1` | OpenSSH install + IMDSv2 key retrieval |
| `shared/scripts/ServerCore.ps1` | AppCompat/IE capabilities for Core installs |
| `shared/templates/bootstrap.pkrtpl.hcl` | EC2 user-data WinRM bootstrap |
| `shared/templates/agent-config.pkrtpl.hcl` | EC2Launch v2 agent configuration |
| `shared/templates/amazon-ssm-agent.pkrtpl.hcl` | SSM agent configuration |
| `shared/ansible/vars/common.yaml` | Shared package lists and passwords |
