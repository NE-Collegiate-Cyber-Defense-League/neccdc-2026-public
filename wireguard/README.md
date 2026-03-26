# Ansible Wireguard

Wireguard Ansible setup

Updated to work on arm instances. Recommended base instance type of `t4g.micro`.

Uses [wg-easy](https://github.com/wg-easy/wg-easy) for easier deployment on containers and api to setup clients.

## Inputs

| Variable                      | Description                                                       |
| ----------------------------- | ----------------------------------------------------------------- |
| wireguard_subnet_black_team   | Network range for black team wireguard clients. ex "172.16.127.x" |
| wireguard_subnet_red_team     | Network range for red team wireguard clients. ex "172.16.128.x"   |
| wireguard_subnet_blue_team    | Network range to put blue team wireguard clients. ex "172.16"     |
| wireguard_client_dns          | String containing ip addresses to use for dns                     |
| wireguard_admin_username      | Wireguard admin username                                          |
| wireguard_admin_password      | Wireguard admin password                                          |
| wireguard_black_team_password | Black team wireguard password                                     |
| black_team_clients            | List of black team client names                                   |
| red_team_clients              | List of red team client names                                     |
| number_of_teams               | Number of teams to create. starting index of 0                    |
| output_dir                    | Location of the zip of the client configuration                   |


## Backup
Download the black team wg-easy database with this command

```bash
scp -i ~/ccdc/neccdc-2026/documents/black_team/id_rsa ubuntu@vpn.chefops.tech:/opt/wireguard/wireguard-black-team/wg-easy.db ./files/wg-easy.db
```

## Recovery

Once the server has been deployed once it can be redeployed by moving it back to a servers `/opt/wireguard` directory which will be picked up by the deployment.

Once that is completed run the playbook with the **base** tag.

```bash
ansible-playbook playbook.yaml --tags base
```


## Troubleshooting
If there is an error during the playbook buildout Its usually easier to just remove all the wireguard containers and rerun the ansible

```bash
docker rm -f $(docker ps -aq)
rm -rf /opt/wireguard
```
