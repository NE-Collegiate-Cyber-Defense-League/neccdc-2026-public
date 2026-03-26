# Legacy Systems & Incident Response

Notes for working with Ocean Crest’s legacy restaurant systems and for incident response using the available playbooks and tooling.

## Legacy systems (Ocean Crest)

- Ocean Crest is **modernizing legacy restaurant systems**. Operations and security work must account for:
  - **Change windows**: Prefer maintenance and disruptive changes (reboots, Teleport restarts, Falco reloads) during agreed windows.
  - **Dependencies**: Legacy POS or back-office systems may depend on specific network (pfSense), Kiosk, POS, or monitoring (Alloy) behavior—document and test before changes.
  - **Backups**: Always run **pfsense-backup.yaml** or similar (or confirm recent backups) before major changes or cutovers.
- Keep an internal list of legacy components and their owners; update as modernization progresses.

## Incident response — tooling

- **Falco**: Runtime detection. To roll out new or updated rules:
  1. Update rules in Gitea (e.g., `falco` repo or the URL used by the playbook).
  2. Run **falco-update-rules.yaml** against `falco_clients` to pull and reload.
  3. Use **test-falco-alert.yaml** to confirm alerting works.
- **Teleport**: If access or config is broken, use **teleport-operation.yaml** with `teleport_operation: restart` after fixing config.
- **Alloy**: After config fixes, run **alloy-reload.yaml** to deploy and reload; validate config when possible.
- **Compliance**: Run **compliance-check.yaml** as part of post-incident review (world-writable files in `/etc`, SSH settings). Use `compliance_fail_critical: true` only when you intend to enforce SSH hardening.

## Incident response — backups

- **Restore pfSense**: Use a backup from `backups/pfsense/`; restore via pfSense UI or documented procedure.
- **Restore Kiosks**: Restore from a known backup and setup ChefOps tools Teleport/Falco/Alloy.

## Escalation and documentation

- Document incidents and decisions (e.g., in tickets or emails); reference which playbooks were run and any legacy systems affected.
- For Ocean Crest, align communication and escalation with the contract and any legacy modernization project leads.
