# Windows Post-Configuration Playbooks

Ansible playbooks for post-deployment configuration of the Windows infrastructure used in the NECCDC 2026 qualifiers. This covers domain controller setup, ADFS configuration, and POS workstation domain joining.

## Structure

```
qualifiers/post/windows/
├── playbook.yaml          # Main entry point
├── tasks/
│   ├── 01_dc.yaml         # Domain Controller setup
│   ├── 02_adfs.yaml       # ADFS setup
│   └── 03_pos.yaml        # POS workstation domain join
├── roles/
│   ├── base.win/          # Base Windows configuration
│   ├── populate.users/    # AD user/group population from CSV
│   ├── adcs/              # Active Directory Certificate Services
│   ├── ludus_wsus/        # WSUS configuration
│   ├── bginfo/            # BGInfo deployment
│   └── bginfo.local/      # BGInfo local configuration
└── files/
    ├── users/
    │   └── users.csv      # User/group definitions for AD population
    └── req-adfs.ps1       # ADFS certificate request script
```

## Playbooks

### `playbook.yaml` — Main Entry Point

Imports all task playbooks in order. Tags can be used to run specific components:

| Tag    | Playbook        | Description              |
|--------|-----------------|--------------------------|
| `dc`   | `tasks/01_dc.yaml`   | Domain Controller setup |
| `adfs` | `tasks/02_adfs.yaml` | ADFS configuration      |
| `pos`  | `tasks/03_pos.yaml`  | POS workstation join    |

### `tasks/01_dc.yaml` — Domain Controller

Targets: `windows_ad`

1. Applies `base.win` role — sets hostname, configures DNS (firewall private IP), syncs NTP, prefers IPv4.
2. Promotes the host to a primary domain controller using `microsoft.ad.domain`.
3. Creates `black-team` and `ssm-user` service accounts as Domain/Enterprise Admins (retries up to 30× while AD stabilizes).
4. Runs `populate.users` role to import users and groups from `files/users/users.csv`.
5. Runs `adcs` role to install and configure a Certificate Authority (`<NETBIOS>-CA`).
6. Creates DNS A records for `sts` and `certauth.sts` pointing to the ADFS server IP.

### `tasks/02_adfs.yaml` — ADFS Server

Targets: `windows_adfs`

1. Applies `base.win` role — sets hostname, configures DNS to point at the DC, syncs NTP, prefers IPv4.
2. Joins the host to the Active Directory domain and reboots if required.
3. Requests an SSL certificate from the ADCS CA using the `SSLCertificateTemplate` template with SANs for `<hostname>.<domain>`, `sts.<domain>`, and `certauth.sts.<domain>`.
4. Creates a KDS Root Key (required for gMSA/ADFS service accounts).
5. Runs `ludus_wsus` role to configure WSUS.

### `tasks/03_pos.yaml` — POS Workstations

Targets: `windows_pos`

1. Applies `base.win` role — sets hostname, configures DNS to point at the DC, syncs NTP. IPv4 preference disabled.
2. Joins the host to the Active Directory domain and reboots if required.

## Roles

| Role            | Description |
|-----------------|-------------|
| `base.win`      | Sets hostname, DNS servers, NTP, and IPv4/IPv6 preference |
| `populate.users`| Creates AD users and groups from a CSV file |
| `adcs`          | Installs and configures Active Directory Certificate Services |
| `ludus_wsus`    | Configures Windows Server Update Services |
| `bginfo`        | Deploys BGInfo for desktop environment information display |
| `bginfo.local`  | Local BGInfo configuration |

## Required Variables

These variables must be defined in your inventory or `group_vars`:

| Variable | Description |
|---|---|
| `hostname` | Target machine hostname |
| `ad.domain` | Active Directory domain name (e.g. `corp.example.com`) |
| `ad.netbios` | AD NetBIOS name (e.g. `CORP`) |
| `adserver_domain` | Domain name used during domain join |
| `ansible_password` | Administrator password (also used as DSRM password) |
| `black_team_password` | Password for `black-team` and `ssm-user` accounts |
| `team_address.firewall_private.ipv4` | Firewall private IPv4 (used as DNS for DC) |
| `team_address.firewall_private.ipv6` | Firewall private IPv6 (optional) |
| `team_address.windows_ad.ipv4` | DC IPv4 (used as DNS for ADFS/POS) |
| `team_address.windows_ad.ipv6` | DC IPv6 (optional) |
| `team_address.windows_adfs.ipv4` | ADFS server IPv4 (used for DNS records) |

## Usage

Run all playbooks:
```bash
ansible-playbook playbook.yaml -i <inventory>
```

Run a specific component using tags:
```bash
# Domain Controller only
ansible-playbook playbook.yaml -i <inventory> --tags dc

# ADFS only
ansible-playbook playbook.yaml -i <inventory> --tags adfs

# POS workstations only
ansible-playbook playbook.yaml -i <inventory> --tags pos
```

Target a specific host or group:
```bash
ansible-playbook playbook.yaml -i <inventory> --limit windows_ad
```
