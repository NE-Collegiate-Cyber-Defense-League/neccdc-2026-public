# Ansible Role: ludus_wsus

An Ansible Role that installs [Windows Server Update Services (WSUS)](https://learn.microsoft.com/en-us/windows-server/administration/windows-server-update-services/get-started/windows-server-update-services-wsus) on Windows Server and optionally configures products, classifications, and synchronization schedules.

## Requirements

None. This role should work on Windows Server 2012 R2 and newer, but has only been tested on Windows Server 2016, 2019, 2022, and 2025.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

### Storage Configuration

```yaml
# Update storage location
ludus_wsus_content_folder: 'C:\WSUS\Content'
# Log file location
ludus_wsus_log_folder: 'C:\WSUS\Logs'
```

### Update Source

```yaml
# Sync from Microsoft Update (true) or upstream WSUS (false)
ludus_wsus_sync_from_mu: true

# Upstream WSUS server configuration (used when ludus_wsus_sync_from_mu is false)
ludus_wsus_upstream_server_name: ''
ludus_wsus_upstream_server_port: 8530
ludus_wsus_upstream_server_use_ssl: false
ludus_wsus_upstream_server_replica: false
```

### Proxy Configuration

```yaml
# Proxy server (empty = no proxy)
ludus_wsus_proxy_name: ''
ludus_wsus_proxy_port: 80
ludus_wsus_proxy_user_name: ''
ludus_wsus_proxy_password: ''
```

### Products and Classifications

```yaml
# Empty by default - configure manually in GUI or specify products here
ludus_wsus_products_list: []
  # Example:
  # - 'Windows Server 2016'
  # - 'Windows Server 2019'
  # - 'Microsoft Server operating system-21H2'  # Windows Server 2022
  # - 'Microsoft Server Operating System-24H2'  # Windows Server 2025

# Empty by default - configure manually in GUI or specify classifications here
ludus_wsus_classifications_list: []
  # Example:
  # - 'Critical Updates'
  # - 'Security Updates'
  # - 'Definition Updates'

# Update languages to synchronize
ludus_wsus_update_languages:
  - en
```

### Client Configuration

```yaml
# Targeting mode: 'Server' = server-side, 'Client' = client-side targeting
ludus_wsus_targeting_mode: 'Server'
# Computer target groups to create
ludus_wsus_computer_target_group_list:
  - 'Domain Controllers'
  - 'Servers'
  - 'Workstations'
```

### Synchronization

```yaml
# Perform initial sync during deployment (can take hours depending on products/classifications)
ludus_wsus_initial_sync: false
# Wait for synchronization to complete
ludus_wsus_wait_for_sync: false
# Synchronization timeout in seconds
ludus_wsus_sync_timeout: 14400
# Initial category sync timeout in minutes
ludus_wsus_category_sync_timeout_minutes: 60

# Enable automatic synchronization schedule
ludus_wsus_enable_auto_sync: false
# Local time for first sync (automatically converted to UTC for WSUS)
ludus_wsus_sync_daily_time:
  hour: 3
  minute: 0
# Number of synchronizations per day (1-24)
ludus_wsus_syncs_per_day: 1
```

### Additional Settings

```yaml
# Auto-approve updates using default approval rule
ludus_wsus_enable_default_approval_rule: false
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: wsus_servers
  roles:
    - 5tuk0v.ludus_wsus
  vars:
    ludus_wsus_products_list:
      - 'Microsoft Server operating system-21H2'
    ludus_wsus_classifications_list:
      - 'Critical Updates'
      - 'Security Updates'
    ludus_wsus_enable_auto_sync: true
```

## Example Ludus Range Config

```yaml
ludus:
  - vm_name: "{{ range_id }}-wsus-win2022-server-x64"
    hostname: "{{ range_id }}-wsus"
    template: win2022-server-x64-template
    vlan: 10
    ip_last_octet: 11
    ram_gb: 4
    cpus: 2
    windows:
      sysprep: true
    domain:
      fqdn: ludus.domain
      role: member
    roles:
      - 5tuk0v.ludus_wsus
    role_vars:
      ludus_wsus_products_list:
        - 'Microsoft Server operating system-21H2'
      ludus_wsus_classifications_list:
        - 'Critical Updates'
        - 'Security Updates'
      ludus_wsus_enable_auto_sync: true
      ludus_wsus_syncs_per_day: 2
```

## License

GPLv3

## Author Information

This role is a rewrite and enhancement of [@gamethis](https://github.com/gamethis)'s [ansible_role_wsus_server](https://github.com/gamethis/ansible_role_wsus_server), adapted for [Ludus](https://ludus.cloud/) ephemeral lab environments.

This role was created by [5tuk0v](https://github.com/5tuk0v).

- GitHub: [@5tuk0v](https://github.com/5tuk0v)
- Twitter/X: [@stuk0v_](https://twitter.com/stuk0v_)