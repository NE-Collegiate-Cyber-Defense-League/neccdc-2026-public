# neccdc-2026

> [!NOTE]
> **Interested in contributing?**
>
> We're building the premier cyber defense competition and could use your help
> - [Sponsor](https://neccdl.org/sponsor/)
> - [Volunteer](https://neccdl.org/volunteer/black-team/)


## The 2026 Team

- [Andrew Aiken](https://github.com/andrew-aiken)
  - AWS
  - Falco
  - Gitea
  - Semaphore
  - Teleport
- [Andrew Iadevaia](https://github.com/andrewiadevaia)
  - AWS Networking
  - pfSense
  - Windows
- [Evan Soroken](https://github.com/ESoro25)
  - Middlesex Community College onsite black team
  - Deployed and implemented the host networking
- [Jake White](https://github.com/Cyb3r-Jak3)
  - Discord
  - Grafana
  - Kiosks
- [Justin Marwad](https://github.com/justinmarwad)
  - Wordpress
- [Jason Gendron](https://github.com/jasongendron)
  - Developed regionals host network topology
- [Nick Millett](https://github.com/millett-nick)
  - Assistance with Windows
  - Regionals competition support
- [Alex Sheehan](https://github.com/011000100110111101101111)
  - Initial Semaphore playbook setup

# Infrastucture
Have question on how this works?
Join the NECCDL Discord and we would be happy to answer

## Ansible
This directory contains a majority of the code base for shaping the individual hosts and services within the environment.

#### Inventory
Contains the inventory files necessary for ansible to be able to target multiple teams with a inventory group. Utilizing ansible's [inventory load order](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#managing-inventory-load-order) and and a python script we can abstract the creation of the inventory hostvars from individual host -> host groups -> all hosts.
To supplement this, an `ansible.cfg` file is included to specify the inventory file to use.

```bash
export ANSIBLE_CONFIG=$HOME/ccdc/neccdc-2026/ansible/regionals/inventory/ansible.cfg
```

#### Pre
This directory contains all the packer build configurations for the competition.
Each host is either broken down into a separate directory or is grouped into a single directory with multiple hosts based on category.
The directories contain the necessary packer build configurations, typically within a folder named `packer`, and any necessary provisioning scripts located at the same level as the `packer` folder.

#### Post
This directory contains all configuration and setup tasks for anything that could not be completed in the [Packer](#Pre) stage. (Due to having team identifiers in the project)
The majority of the codebase is Ansible with some special scripts for edge cases ansible could not handle. Similar to the [Pre](#Pre) directory, the [Post](#Post) directory is broken down into individual host directories or grouped into a single directory with multiple hosts based on category.

## Scorestack
This directory contains the necessary resources to provision the scorestack engine for the competition.
The scorestack engine is provisioned and controlled solely through ansible.

## Terraform
This directory contains the necessary resources to provision the infrastructure for the competition on AWS.

### IPAM
Setups the public IPv6 addresses range that we could reuse throughout the season.
Moved outside of qualifiers and regionals since the range was reused between both competitions.

### Environments

### Black
The base infrastructure that is shared between all teams.
Networking, VPN, ipsec, scorestack, etc.

### Blue
Each team has an unique workspace based on their ID.
Deploys the networking, instances and public DNS.

### Certificates
Public TLS certificates for scoring, vpn and unique certificate for each teams services.

## Note
Qualifiers deployment may not fully work as expected since we've updated the repository for regionals.
