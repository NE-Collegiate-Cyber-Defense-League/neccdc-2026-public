# Black Team Shared

## Inputs

| Variable               | Description                             | Default                              |
| ---------------------- | --------------------------------------- | ------------------------------------ |
| root_groups            | Groups to add the black team user to    | **sudo**                             |
| black_team_password    | Password to set for the black team user | **dfgbfecn4uMtYxcqEdA3WQcdBgH2QGxM** |
| ssh_service_name       | Systems SSH service                     | **sshd**                             |
| shell_override         | Users shell                             | **/bin/bash**                        |
| shell_config_override  | Users shell config                      | **.bashrc**                          |
| shell_command_override | Command always run in shell             | **cat /home/black-team/readme.md**  |

## Usage

```yaml
- name: Run black team tasks
  ansible.builtin.include_tasks:
    file: "../../shared/black_team/main.yaml"
  vars:
    root_groups: admin,sudo,docker
```
