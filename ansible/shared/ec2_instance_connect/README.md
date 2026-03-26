# Setup EC2 Instance Connect

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html

## Usage

All tasks use the `eic` tag

```yaml
- name: Install EIC
  ansible.builtin.include_tasks:
    file: "../../../shared/ec2_instance_connect/main.yaml"
  tags:
    - eic
```
