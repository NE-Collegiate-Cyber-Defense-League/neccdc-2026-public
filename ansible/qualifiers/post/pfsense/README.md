# pfSense Post-Configuration Ansible Playbook

Configures pfSense after initial provisioning by rendering a full `config.xml` from Jinja2 templates and applying it to the firewall host.

## What It Does

1. **Loads team TLS certificate material** from the documents directory (cert, private key, CA bundle) into playbook vars.
2. **Installs the pfSense RESTAPI package** (`jaredhendrickson13/pfsense-api`) via `pkg-static` if not already present.
3. **Renders and deploys `/conf/config.xml`** from the Jinja2 template tree, overwriting the existing pfSense configuration.
4. **Reboots pfSense** to apply the new configuration.
5. **Clears all log files** via `pfSsh.php playback clearlogfiles`.

## Requirements

- Target host must be in the `firewall` inventory group.
- SSH access to pfSense (no `become` — runs as the admin user directly).
- Team certificate files must exist at the paths defined in `vars/certs.yaml` relative to the repo root:
  - `documents/blue_team/qualifiers/team_<N>/certificates/cert.crt`
  - `documents/blue_team/qualifiers/team_<N>/certificates/private.key`
  - `documents/blue_team/qualifiers/team_<N>/certificates/cabundle.crt`

## Usage

```bash
ansible-playbook playbook.yaml -e "team=<team_number>"
```

To skip loading team certificates (e.g., testing without cert files):

```bash
ansible-playbook playbook.yaml -e "team=<team_number> load_team_certs=false"
```

## Variables

### `vars/main.yaml`

| Variable | Description |
|---|---|
| `pfsense_version` | pfSense version to target (`24.11` or `25.11`) |
| `interfaces.*` | Per-interface config (IP, prefix, description) for PUBLIC, PRIVATE, SCREENED, BRANCH |
| `unbound_custom_options` | Unbound DNS overrides for team-specific service FQDNs |

### `vars/certs.yaml`

| Variable | Description |
|---|---|
| `certs.team.cert` | Team TLS certificate (loaded from file at runtime) |
| `certs.team.ca` | Team CA bundle (loaded from file at runtime) |
| `certs.system` | Pre-baked system/GUI certificate (base64-encoded) |
| `certs.sshdata` | SSH host key material embedded in config.xml |

## Template Structure

```
templates/
└── pfsense.xml.j2              # Root config.xml template
    ├── pfsense/system/
    │   ├── _system.xml.j2      # Hostname, WebGUI, SSH, timezone, sshguard
    │   └── _users.xml.j2       # Local user accounts
    ├── pfsense/network/
    │   ├── _interfaces.xml.j2  # WAN/LAN/OPT1/OPT2 interfaces + VIP + gateways
    │   ├── _nat.xml.j2         # NAT/port-forward rules
    │   ├── _unbound.xml.j2     # Unbound DNS resolver config
    │   └── firewall/
    │       ├── _aliases.xml.j2 # Firewall aliases
    │       └── _filter.xml.j2  # Firewall filter rules
    └── pfsense/extra/
        ├── _settings.xml.j2    # Misc pfSense settings
        ├── _certs.xml.j2       # Certificate/CA store entries
        └── packages/
            ├── _restapi.xml.j2 # pfSense RESTAPI package config
            ├── _haproxy.xml.j2 # HAProxy load balancer config
            ├── _sudo.xml.j2    # Sudo package config
            └── _nexus.xml.j2   # Nexus package config
```

## Network Interfaces

| Interface | pfSense Name | Description | Addressing |
|---|---|---|---|
| `ena0` | `wan` | PUBLIC | DHCP / DHCPv6 |
| `ena1` | `lan` | PRIVATE | Static IPv4 `/25`, Static IPv6 `/64` |
| `ena2` | `opt1` | SCREENED | Static IPv4 `/26` |
| `ena3` | `opt2` | BRANCH | Static IPv6 `/64` |

A VIP alias is configured on the LAN interface at `team_address.firewall_vip.ipv4` for WebGUI access.

## Firewall Rules (Default)

- **WAN**: Allow IPv6 link-local, ICMP, SSH (22), HTTP (80), HTTPS (443), management port alias, all traffic (catch-all)
- **LAN (PRIVATE)**: Allow IPv6 link-local + multicast, all LAN to any
- **OPT1 (SCREENED)**: Allow IPv6 link-local + multicast, all SCREENED to any
- **OPT2 (BRANCH)**: Allow IPv6 link-local + multicast, all BRANCH to any (IPv6)

## WebGUI & SSH

- WebGUI: HTTPS on port `8080`, using team TLS certificate
- SSH: Enabled on port `22` with agent forwarding
- SSHguard: Enabled with RFC-1918 whitelist (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`)

## DNS (Unbound)

Custom Unbound overrides resolve team service FQDNs to their internal IPs:

- `<team_domain>` → firewall VIP
- `teleport.<team_domain>`, `falco.<team_domain>`, `grafana.<team_domain>`, `loki.<team_domain>`, `mimir.<team_domain>`, `traefik.<team_domain>`, `semaphore.<team_domain>`
- AD domain set as private + insecure for split-DNS
