# Backup Retention and Schedule

Reference for ChefOps and Ocean Crest Kitchens backup retention and suggested schedules.

## Retention (recommended minimums)

| Asset          | Retention            | Notes                                      |
| -------------- | -------------------- | ------------------------------------------ |
| pfSense config | 30 days + pre-change | Keep last known-good before firewall edits |
| POS DB         | 7 days (default)     | Increase if compliance or RPO requires     |

Adjust any external retention (e.g., archive storage) to match policy.

## Schedule (suggested)

| Backup         | Frequency                               | Preferred window          |
| -------------- | --------------------------------------- | ------------------------- |
| pfSense config | Daily or weekly; always pre/post change | Off-peak or maintenance   |
| POS DB         | Daily                                   | Low-traffic (e.g., 02:00) |

Use Semaphore or cron on the Ansible controller/runner to run the playbooks; document the exact schedule in your runbook.

## Ocean Crest–specific

- Coordinate with Ocean Crest’s modernization and legacy system maintenance windows.
- Avoid backup jobs during known POS or legacy system cutovers unless required for change rollback.
