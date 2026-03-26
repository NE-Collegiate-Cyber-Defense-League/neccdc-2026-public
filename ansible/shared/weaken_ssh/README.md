# Weaken SSH

An improvement to this play would be to put some in sshd config directory instead of main file

## Variables

| Name                      | Description                                    | Default                  |
| ------------------------- | ---------------------------------------------- | ------------------------ |
| ssh_config_path           | SSH config path                                | **/etc/ssh/sshd_config** |
| ssh_service_name          | Systems SSH service                            | **sshd**                 |

Example usage

```yaml
- name: Weaken SSH
  ansible.builtin.include_tasks:
    file: "../../../shared/weaken_ssh/main.yaml"
  vars:
    ssh_config_path: /etc/ssh/sshd_config
  tags:
    - ssh
```
