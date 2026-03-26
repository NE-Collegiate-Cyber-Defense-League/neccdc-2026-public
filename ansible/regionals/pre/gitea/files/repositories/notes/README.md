# Operational Notes — ChefOps & Ocean Crest Kitchens

Notes for security and operations at **ChefOps** and Client. Use these alongside the Ansible playbooks in the `ansible` repository.

## Context

- **ChefOps**: Managed Service Provider for food services. Responsibilities include protecting internal infrastructure and client environments.
- **Ocean Crest Kitchens**: Regional chain; initial contract includes modernization of legacy restaurant systems. Work covers core infrastructure, monitoring, access management, and incident response.

## Contents

| Document | Purpose |
|----------|---------|
| [Client-and-engagement.md](Client-and-engagement.md) | Ocean Crest engagement summary, scope, and legacy considerations |
| [runbooks-and-playbooks.md](runbooks-and-playbooks.md) | When to run which playbook; quick reference |
| [legacy-and-incident.md](legacy-and-incident.md) | Legacy systems notes and incident response pointers |

## Related repos

- **ansible** — Standalone playbooks (backups, Falco, Alloy, Teleport, compliance, etc.)
- **backups** — Backup procedures, retention, and artifact locations
- **falco** — Falco rules (e.g., custom rules consumed by `falco-update-rules.yaml`)
