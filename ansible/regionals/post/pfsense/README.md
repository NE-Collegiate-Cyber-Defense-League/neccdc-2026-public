# pfSense Post-Configuration Playbooks

Ansible playbooks for post-deployment configuration of the pfSense firewalls used in the NECCDC 2026 regionals. Two firewall roles — **corp** and **branch** — are each configured by rendering a Jinja2 XML template to `/conf/config.xml` and rebooting.

## Structure

```
regionals/post/pfsense/
├── playbook.yaml               # Main entry point — runs corp then branch
├── playbook_corp.yaml          # Corporate firewall configuration
├── playbook_branch.yaml        # Branch office firewall configuration
├── tasks/
│   └── main.yaml               # Shared tasks: render config.xml + reboot
├── templates/
│   ├── firewall_corp.xml.j2    # pfSense config template for corp
│   └── firewall_branch.xml.j2  # pfSense config template for branch
└── files/
    └── pfsense_exporter.sh     # Prometheus metrics exporter (runs via cron)
```

## Playbooks

### `playbook.yaml` — Main Entry Point

Runs both firewall playbooks in sequence.

```bash
ansible-playbook playbook.yaml -i <inventory>
```

### `playbook_corp.yaml` — Corporate Firewall

Targets: `firewall_corp`

- Renders `firewall_corp.xml.j2` → `/conf/config.xml`
- Loads team certificates from `documents/blue_team/regionals/chefops/team_{{ team }}/certificates/`
- DNS resolver private zones for corp and branch AD domains
- Teleport DNS redirect → `team_address.teleport_corp` (IPv6)
- Static route: `10.100.{{ team }}.0/24` via WireGuard gateway `WG_VPN_SAT_V4`

```bash
ansible-playbook playbook_corp.yaml -i <inventory>
```

### `playbook_branch.yaml` — Branch Office Firewall

Targets: `firewall_branch`

- Renders `firewall_branch.xml.j2` → `/conf/config.xml`
- Loads team certificates from `documents/blue_team/regionals/ock/team_{{ team }}/certificates/`
- DNS resolver private zones for corp and branch AD domains
- Teleport DNS redirect → `team_address.teleport_branch` (IPv4 + IPv6)
- Static route: `10.3.{{ team }}.0/24` via WireGuard gateway `WG_VPN_HQ_V4`

```bash
ansible-playbook playbook_branch.yaml -i <inventory>
```

## Firewall Comparison

| Feature | Corp (`firewall_corp`) | Branch (`firewall_branch`) |
|---------|------------------------|----------------------------|
| Interfaces | WAN, LAN (IPv6), DMZ (IPv4+IPv6) | WAN, LAN (IPv4+IPv6) |
| WireGuard peer | Satellite — `WG_VPN_SAT_V4` (`192.168.1.0/31`) | HQ — `WG_VPN_HQ_V4` (`192.168.1.1/31`) |
| VPN static route | `10.100.{{ team }}.0/24` | `10.3.{{ team }}.0/24` |
| Cert path | `regionals/chefops/team_{{ team }}/` | `regionals/ock/team_{{ team }}/` |
| Teleport IPs | `teleport_corp` (IPv6 only) | `teleport_branch` (IPv4 + IPv6) |
| LDAP servers | Corp AD only | Corp AD + Branch AD |
| Extra DNS hosts | Traefik, Grafana, Loki, Mimir, Semaphore, Gitea | — |

## Required Variables

| Variable | Description |
|----------|-------------|
| `team` | Team number — used in IP ranges and cert paths |
| `hostname` | pfSense hostname |
| `domains.corp.ad` | Corporate AD domain (e.g. `ad.chefops.local`) |
| `domains.branch.ad` | Branch AD domain (e.g. `ad.oceancrests.local`) |
| `domains.corp.team` | Corp team domain (e.g. `chefops.local`) |
| `domains.branch.team` | Branch team domain (e.g. `ock.local`) |
| `team_address.firewall_corp_private.ipv6` | Corp LAN IPv6 |
| `team_address.firewall_corp_dmz.ipv4` | Corp DMZ IPv4 |
| `team_address.firewall_corp_dmz.ipv6` | Corp DMZ IPv6 |
| `team_address.firewall_branch_private.ipv4` | Branch LAN IPv4 |
| `team_address.firewall_branch_private.ipv6` | Branch LAN IPv6 |
| `team_address.teleport_corp.ipv6` | Teleport server IPv6 (corp) |
| `team_address.teleport_branch.ipv4` | Teleport server IPv4 (branch) |
| `team_address.teleport_branch.ipv6` | Teleport server IPv6 (branch) |
| `team_address.corp_win_dc.ipv6` | Corporate DC IPv6 |
| `team_address.corp_win_srv.ipv6` | Corporate Windows server IPv6 |
| `team_address.branch_win_dc.ipv4` | Branch DC IPv4 |
| `team_address.branch_win_dc.ipv6` | Branch DC IPv6 |
| `team_address.grafana.ipv6` | Grafana IPv6 |
| `team_address.semaphore.ipv6` | Semaphore IPv6 |
| `team_address.gitea.ipv6` | Gitea IPv6 |

## Configuration Applied

Both templates configure pfSense v24.11 with:

**System**
- 3 local users: `admin`, `black-team`, `ec2-user` (SSH key auth)
- LDAP authentication against corp and/or branch domain controllers
- SSH on port 22 with agent forwarding, web GUI on port 8080 (HTTPS)
- SSL certificate from team cert path when `load_team_certs: true`
- WireGuard started at boot via `earlyshellcmd`
- Timezone: `US/Eastern`, NTP: `2.pfsense.pool.ntp.org`
- Max state table entries: 400,000

**Firewall / NAT**
- Automatic outbound NAT
- WAN ingress open, ICMPv4/v6 echo permitted
- Management ports: SSH (22), HTTP (8080), HTTPS (443/8443)
- WireGuard UDP 51820 forwarded on WAN

**DNS (Unbound)**
- Private/insecure zones for both AD domains
- Domain overrides pointing to respective DCs
- Local-zone entries for Teleport (both environments)
- Corp only: host entries for Traefik, Grafana, Loki, Mimir, Semaphore, Gitea
- Full access list (0.0.0.0/0 and ::/0), prefetch and caching enabled

**Packages**
- `sudo` — privilege delegation
- `haproxy` — TCP/HTTP(S) load balancing
- `node_exporter` — Prometheus metrics
- WireGuard, Netgate Nexus

## Monitoring (`files/pfsense_exporter.sh`)

Runs every minute via cron and writes Prometheus `.prom` files to `/var/tmp/node_exporter/`:

| File | Metrics |
|------|---------|
| `node_pfsense_firewall.prom` | PF state table size/limits, per-interface packet and byte counters (direction × protocol × action) |
| `node_pfsense_gateway.prom` | Gateway RTT, jitter, packet loss, up/down status |
| `node_pfsense_interface.prom` | RX/TX bytes, packets, errors, drops for `ena*` and `tun_wg*` interfaces |
| `node_pfsense_wireguard.prom` | Tunnel/peer up status, last handshake age, per-peer RX/TX bytes |
| `node_pfsense_unbound.prom` | Query rates, cache hit/miss, DNSSEC validation, response codes, memory usage, per-thread stats |

The script resolves WireGuard public keys to human-readable peer names using comments in the WireGuard config file.
