# Client & Engagement Notes

## Ocean Crest Kitchens

### Client summary

- **Name**: Ocean Crest Kitchens  
- **Industry**: Regional restaurant chain (food services)  
- **Contract**: Initial engagement with ChefOps as Managed Service Provider  
- **Focus**: Modernization of legacy restaurant systems; core infrastructure, monitoring, access management, incident response  

### Scope (ChefOps responsibilities)

- **Infrastructure**: Maintain and secure core infrastructure for both ChefOps and Ocean Crest.
- **Monitoring**: Metrics and observability (e.g., Alloy), system status (uptime playbook), and alerting.
- **Access management**: Teleport for access; ensure config and restarts are managed via playbooks.
- **Incident response**: Falco for runtime detection; rule updates and test alerts via playbooks; coordination with legacy systems.
- **Compliance**: Use compliance-check playbook; align with Ocean Crest and ChefOps policy (SSH hardening, file permissions).
- **Backups**: pfSense configs and Kiosk; see `backups/` for procedures and retention.

### Legacy systems

- Ocean Crest is modernizing **legacy restaurant systems**. Document which systems are legacy (POS, back-office, network) and any constraints:
  - Maintenance windows, **don't turn off their Kiosks during operational hours**
    - Don't delete all their employee accounts
  - No automatic reboots or invasive changes without approval
  - Dependencies that affect monitoring (Alloy) or access (Teleport)
- Keep runbooks and change procedures aligned with legacy cutover plans.

### Playbooks that apply to this engagement

- **Backups**: `pfsense-backup.yaml`
- **Monitoring**: `alloy-reload.yaml`, `uptime-system-status-cron.yaml`  
- **Security / IR**: `falco-update-rules.yaml`, `test-falco-alert.yaml`, `compliance-check.yaml`  
- **Access**: `teleport-operation.yaml`  
- **Maintenance**: `update-software-package.yaml`, `reboot-server.yaml`  

See [runbooks-and-playbooks.md](runbooks-and-playbooks.md) for when and how to run them.
