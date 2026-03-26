# Teleport Client

This role installs and configures the Teleport client for SSH and application access.

## Variables

### Required Variables

- **`teleport_node_name`** (string)
  - The unique name for this Teleport node
  - Example: `"falco-controller"`, `"web-server-01"`

- **`teleport_join_token`** (string)
  - The token used to authenticate this node when joining the Teleport cluster
  - Obtain from your Teleport Auth server
  - Example: `"STF5Y7KCA80S7IOHEPUNVB6SRMTX1U78"`

### Optional Variables

- **`teleport_node_label`** (dictionary)
  - Key-value pairs used to label and identify this node in Teleport
  - Used for RBAC and node selection
  - Example:
    ```yaml
    teleport_node_label:
      service: falco
      environment: production
    ```

- **`teleport_app_service_enabled`** (string: "yes" or "no", default: "no")
  - Whether to enable the Teleport application service on this node
  - Set to `"yes"` to proxy web applications through Teleport
  - Example: `"yes"`

- **`teleport_apps`** (list of dictionaries, default: undefined)
  - List of applications to register with Teleport's application service
  - Only used when `teleport_app_service_enabled` is `"yes"`
  - Each app dictionary supports:
    - **`name`** (required): Application name in Teleport
    - **`uri`** (required): Backend URL of the application
    - **`labels`** (optional): Dictionary of labels for the app
    - **`insecure_skip_verify`** (optional): Boolean to skip TLS verification
  - Only supports whats noted, but can be expanded to support other [config args](https://goteleport.com/docs/reference/deployment/config/#application-service)
  - Example:
    ```yaml
    teleport_apps:
      - name: falcosidekick
        uri: "http://localhost:2802"
        labels:
          service: falcosidekick
      - name: grafana
        uri: "https://localhost:3000"
        insecure_skip_verify: true
        labels:
          service: monitoring
    ```

## Example

```yaml
- name: Install Teleport client
  ansible.builtin.include_tasks:
    file: "../../../shared/teleport_client/main.yaml"
  vars:
    teleport_node_name: "{{ server_name }}"
    teleport_join_token: STF5Y7KCA80S7IOHEPUNVB6SRMTX1U78
    teleport_node_label:
      service: falco
    teleport_app_service_enabled: "yes"
    teleport_apps:
      - name: falcosidekick
        uri: "http://localhost:2802"
        labels:
          service: falcosidekick
  tags:
    - teleport
```

## Notes

- The Teleport service is stopped and disabled by default after installation
- Enable and start the service in your post-configuration playbooks with team-specific settings
- Doc partially written by AI
