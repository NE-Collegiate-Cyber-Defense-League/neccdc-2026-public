## General Setup

Add this to your shell profile script (bashrc/zshrc) and update the path to match your setup

```bash
export ANSIBLE_CONFIG=$HOME/ccdc/neccdc-2026/ansible/qualifiers/inventory/ansible.cfg
```

### Usage

To view all of the hosts and variables

```bash
ansible-inventory --list --flush-cache
```

## Generating Inventory

The initial inventory is generated with a python script since the team environments are a mix between ipv4 & ipv6 and a builtin loop did not suffice.

For development set the `teams` to **0** this will only setup the black team environment. When actually deploying set it to the total number of blue teams.

**Requires python yaml module installed**

```bash
python3 inventory-generator.py
# Starting team (int): 0
# Ending team (int): 0
# Updated hosts file
```
