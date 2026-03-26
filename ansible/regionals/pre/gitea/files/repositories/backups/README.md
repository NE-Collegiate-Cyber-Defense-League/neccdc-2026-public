# Backup Procedures — ChefOps

This directory holds backup artifacts and documentation for ChefOps-managed infrastructure and Ocean Crest Kitchens client environments.

## Scope

- **ChefOps**: Internal MSP infrastructure (monitoring, access, automation).
- **Ocean Crest Kitchens**: Client regional chain; legacy restaurant systems under modernization. Backups cover network (pfSense), web/app (kiosks), Windows and any centralized configs.

## Backup Types

### 1. pfSense configuration

- **Playbook**: `ansible/pfsense-backup.yaml`
- **Target**: Hosts in the `pfsense` group (firewall/routers).
- **What**: Full config XML (`/cf/conf/config.xml`) pulled via SSH.
- **Destination**: Runner writes to `backups/pfsense/` with naming: `{{ hostname }}-{{ epoch }}.xml`.
- **Schedule**: Run before/after firewall changes and on a recurring schedule (e.g., daily or weekly via Semaphore/cron).
- **Retention**: Define in runbook/schedule; recommend at least 30 days and before major changes.

## Running Backups

```bash
# pfSense (from controller or runner with SSH to pfSense)
ansible-playbook -i inventory pfsense-backup.yaml
```

## Retention and Compliance

- Document retention in **notes/retention-and-compliance.md** and keep it aligned with client and ChefOps policy.
- Ensure backup storage (and any copy to this repo) is access-controlled and encrypted where required.

## Directory Layout

- `pfsense/` — Created by the pfSense backup playbook; holds timestamped config XMLs. Add a `.gitignore` if these should not be committed.
