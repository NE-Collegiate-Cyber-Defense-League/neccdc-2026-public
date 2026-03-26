# Runbooks & Playbook Reference

Quick reference for when to use each Ansible playbook in the `ansible` repository. All playbooks are standalone; use inventory and group_vars/host_vars or `-e` / vault as needed.

## Backups

| Playbook                     | When to run                                              | Host group  |
| ---------------------------- | -------------------------------------------------------- | ----------- |
| **pfsense-backup.yaml**      | Before/after firewall changes; on schedule (e.g., daily) | `pfsense`   |
| **wordpress-db-backup.yaml** | Daily DB backup; ensure `db_password` and retention set  | `wordpress` |

See `backups/README.md` and `backups/retention-and-schedule.md`.

---

## Monitoring & observability

| Playbook                           | When to run                                                                  | Host group        |
| ---------------------------------- | ---------------------------------------------------------------------------- | ----------------- |
| **alloy-reload.yaml**              | After Alloy config change; or reload-only when no config change              | `alloy_agents`    |
| **uptime-system-status-cron.yaml** | On a schedule (e.g., every 5 min via cron on controller) for status snapshot | `all` / inventory |

---

## Security & incident response

| Playbook                    | When to run                                                                        | Host group      |
| --------------------------- | ---------------------------------------------------------------------------------- | --------------- |
| **falco-update-rules.yaml** | After updating rules in Gitea (e.g., `falco/`); pushes rules and reloads Falco     | `falco_clients` |
| **test-falco-alert.yaml**   | To verify Falco alerting (touch/remove test file)                                  | `falco_clients` |
| **compliance-check.yaml**   | Periodic compliance; use `compliance_fail_critical: true` to enforce SSH hardening | `linux`         |

---

## Access management

| Playbook                    | When to run                                         | Host group         |
| --------------------------- | --------------------------------------------------- | ------------------ |
| **teleport-operation.yaml** | After Teleport config change: `reload` or `restart` | `teleport_servers` |

Set `teleport_operation: reload` or `restart` via `-e`.

---

## Maintenance

| Playbook                         | When to run                                                        | Host group                |
| -------------------------------- | ------------------------------------------------------------------ | ------------------------- |
| **update-software-package.yaml** | Patching; full upgrade or specific packages                        | `linux` or `target_hosts` |
| **reboot-server.yaml**           | Planned reboots; override targets with `-e target_hosts=groupname` | `all` or `target_hosts`   |

---

## Example commands

```bash
ansible-playbook -i inventory pfsense-backup.yaml
ansible-playbook -i inventory wordpress-db-backup.yaml --ask-vault-pass
ansible-playbook -i inventory falco-update-rules.yaml
ansible-playbook -i inventory teleport-operation.yaml -e "teleport_operation=restart"
ansible-playbook -i inventory compliance-check.yaml -e "compliance_fail_critical=true"
ansible-playbook -i inventory reboot-server.yaml -e "target_hosts=web_servers"
```

Use Semaphore or cron for scheduled runs (backups, uptime cron, compliance).
