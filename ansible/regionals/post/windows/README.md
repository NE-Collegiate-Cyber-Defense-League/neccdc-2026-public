# Windows Post-Configuration Playbooks

Ansible playbooks for post-deployment configuration of the Windows infrastructure used in the NECCDC 2026 regionals. Provisions two Active Directory environments — **corp** (ChefOps) and **branch** (OceanCrests) — across four machine roles per team.

## Structure

```
regionals/post/windows/
├── playbook.yaml               # Main entry point — runs all four playbooks
├── corp/
│   ├── playbook_dc01.yaml      # ChefOps domain controller
│   ├── playbook_srv01.yaml     # Keycloak identity server
│   └── files/keycloak/         # Pre-built Keycloak database & config
├── branch/
│   ├── playbook_dc02.yaml      # OceanCrests domain controller
│   └── playbook_pos.yaml       # Point-of-Sale terminal
└── shared/
    ├── roles/                  # Role catalog (see below)
    └── vars/
        └── config.json         # Centralized AD configuration (users, groups, OUs, GPOs, ADCS)
```

## Playbooks

### `playbook.yaml` — Main Entry Point

Runs all four playbooks in sequence.

```bash
ansible-playbook playbook.yaml -i <inventory>
```

### Corp: `playbook_dc01.yaml` — ChefOps Domain Controller

Targets: `corp_win_dc`  |  Tags: `create`, `config`

| Tag | Steps |
|-----|-------|
| `create` | Set timezone + hostname → Create AD forest (`ad.chefops.local`) → Create `black-team`, `ssm-user`, `system_admin` accounts |
| `config` | Password policy → UPN suffix (`chefops.tech`) → OUs / users / groups → GPO import → Service accounts → ACLs → DNS forwarders → ADCS install → Alloy agent |

### Corp: `playbook_srv01.yaml` — Keycloak Server

Targets: `corp_win_srv`  |  Tags: `join`, `config`

| Tag | Steps |
|-----|-------|
| `join` | Set timezone + hostname → Configure DNS → Domain join → `gpupdate` → Alloy agent |
| `config` | Deploy pre-built Keycloak database → Inject TLS certs → Import LDAPS CA cert → Start Windows service |

### Branch: `playbook_dc02.yaml` — OceanCrests Domain Controller

Targets: `branch_win_dc`  |  Tags: `create`, `config`

Identical structure to `playbook_dc01.yaml` but for `ad.oceancrests.local`:
- Hostname: `windows-dc02`, UPN suffix: `oceancrests.kitchen`
- ADCS common name: `Oceancrests-ADCS`

### Branch: `playbook_pos.yaml` — Point-of-Sale Terminal

Targets: `branch_win_pos`

Set timezone + hostname → Configure DNS → Domain join (`ad.oceancrests.local`) → `gpupdate` → Alloy agent

---

## How Configuration Works

All AD content — OUs, users, groups, service accounts, GPO mappings, ADCS settings — is defined in a single file:

**`shared/vars/config.json`**

The file is keyed by AD domain name. Each playbook loads it and selects the relevant domain:

```yaml
vars_files:
  - "../shared/vars/config.json"
vars:
  data: "{{ lab[domain] }}"   # domain comes from group_vars (ad.chefops.local or ad.oceancrests.local)
```

Roles then receive `data` or sub-keys of it:

```yaml
- role: "{{ roles_path }}/ad/users"
  config: "{{ data }}"

- role: "{{ roles_path }}/ad/gpo"
  gpo_mappings: "{{ data.gpo_mappings }}"

- role: "{{ roles_path }}/ad/adcs"
  adcs_common_name: "{{ data.adcs.common_name }}"
  adcs_templates: "{{ data.adcs.templates }}"
```

### `config.json` schema

```
lab:
  "ad.chefops.local":
    dc_hostname:         windows-dc01
    netbios:             CHEFOPS
    upn_suffix:          chefops.tech
    dns_servers:         [...]
    trust:               { domain, direction }
    ous:                 [ { name, path, protect } ]
    groups:              [ { name, path, scope, category } ]
    users:               [ { name, sam, upn, password, groups, manager, department, title, totp } ]
    set_accounts:        { svc-keycloak: { password, path, groups }, svc-ldap: { ... } }
    ad_acls:             { acl_name: { for, to, right, inheritance } }
    gpo_mappings:        { folder_name: target_gpo_name }
    adcs:
      common_name:       ChefOps-ADCS
      templates:         ["SSL"]

  "ad.oceancrests.local":
    # same schema, different values
```

To add a user, group, or OU — edit `config.json`. No playbook changes needed.

### Inventory & group_vars

The inventory sets per-group variables that drive domain selection and addressing. Key group variables:

```yaml
# corp_windows group
domain: ad.chefops.local
netbios: CHEFOPS

# branch_windows group
domain: ad.oceancrests.local
netbios: OCEANCRESTS

# all windows hosts
ansible_connection: psrp
ansible_psrp_auth: credssp
ansible_become_method: runas
black_team_password: <shared password>
```

Team-specific IP addresses are provided via `team_address.*` mappings in inventory global vars, keyed by `{{ team }}` (0–10). Alloy observability endpoints also use `team`:

```yaml
alloy_mimir_url: "https://mimir.{{ team }}.chefops.tech/api/v1/push"
alloy_loki_url:  "https://loki.{{ team }}.chefops.tech/loki/api/v1/push"
```

---

## Role Catalog

All roles live in `shared/roles/`.

### Active Directory — `ad/*`

| Role | Description |
|------|-------------|
| `ad/domain_controller` | Creates a new AD forest, installs AD DS, waits for SYSVOL replication |
| `ad/domain_join` | Joins a non-DC host to an existing domain, reboots if required |
| `ad/black-team` | Creates `black-team`, `ssm-user`, and `system_admin` as Domain/Enterprise Admins |
| `ad/users` | Creates OUs, groups, and users from `config.json`; sets manager relationships |
| `ad/password_policy` | Applies the default domain password policy via `Set-ADDefaultDomainPasswordPolicy` |
| `ad/upn` | Adds UPN suffixes to the forest (e.g. `chefops.tech`, `oceancrests.kitchen`) |
| `ad/gpo` | Copies GPO backups from `files/gpo/`, imports and links them at the domain root, runs `gpupdate /force` |
| `ad/service_accounts` | Creates service accounts (e.g. `svc-keycloak`, `svc-ldap`) under Managed Service Accounts |
| `ad/acl` | Sets AD object ACLs (e.g. GenericAll on an OU for a service account) |
| `ad/dns_server` | Configures DNS forwarders on the domain controller |
| `ad/adcs` | Installs and configures AD Certificate Services; creates templates (SSL, ESC variants); enables web enrollment |
| `ad/trusts` | Creates bidirectional forest trusts between corp and branch domains |
| `ad/gMSA` | Creates group Managed Service Accounts and ensures the KDS Root Key exists |
| `ad/dcdiag` | Runs `dcdiag /fix` on domain controllers |
| `ad/gpupdate` | Runs `gpupdate /force` |
| `ad/adfs` | *(Deprecated — migrated to Keycloak for 2026)* |

### Base Infrastructure — `base/*`

| Role | Description |
|------|-------------|
| `base/hostname` | Sets Windows hostname, reboots if required |
| `base/timezone` | Sets Windows time zone (default: `Eastern Standard Time`) |
| `base/dns_client` | Configures DNS servers on network adapters (skips DCs) |
| `base/ipv6` | Disables IPv4 on IPv6-only hosts |

### Identity & Observability

| Role | Description |
|------|-------------|
| `keycloak` | Deploys Keycloak 26.5.4 on Windows: copies pre-built H2 database, injects TLS and LDAPS certs, configures NSSM service |
| `alloy` | Deploys Grafana Alloy agent; templates vary by host type (`dc`, `windows`, `keycloak`); ships metrics to Mimir and logs to Loki |

---

## Usage

Run the full stack for a team:

```bash
ansible-playbook playbook.yaml -i <inventory> -e team=3
```

Run a single environment:

```bash
ansible-playbook corp/playbook_dc01.yaml  -i <inventory> -e team=3
ansible-playbook corp/playbook_srv01.yaml -i <inventory> -e team=3
ansible-playbook branch/playbook_dc02.yaml -i <inventory> -e team=3
ansible-playbook branch/playbook_pos.yaml  -i <inventory> -e team=3
```

Run specific phases with tags:

```bash
# Create domain only (skip user population, GPOs, ADCS, etc.)
ansible-playbook corp/playbook_dc01.yaml -i <inventory> -e team=3 --tags create

# Configure domain (users, GPOs, ADCS) — domain must already exist
ansible-playbook corp/playbook_dc01.yaml -i <inventory> -e team=3 --tags config
```
