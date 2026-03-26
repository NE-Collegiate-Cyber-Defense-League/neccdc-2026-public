# Teleport Corp

Build time: ~40 minutes

## Build
The "old" dev container needed to be used to build due to the very old python3 version on the server.

```bash
export ANSIBLE_CONFIG=/workspaces/neccdc-2026/ansible/regionals/pre/teleport/ansible.cfg
cd /workspaces/neccdc-2026/ansible/regionals/pre/teleport

ansible-playbook playbook.yaml
# or
cd packer
packer build .
```

## Notes
This server is built on Ubuntu 16 which caused a bunch of annoying issues with running modern Ansible.
I was able to install a "newer" python version to be able to run post outside of the dev container.

### Notifications
Pre seeded some for qualifiers but its a fun feature
```
tctl notifications create --user=admin --title="Upcoming Database Maintenance" \
  --content="We will be conducting a database upgrade tomorrow at 2AM UTC"
```

### Database Access
https://goteleport.com/docs/enroll-resources/database-access/enrollment/self-hosted/mysql-self-hosted/

### Trust Cluster
https://goteleport.com/docs/zero-trust-access/deploy-a-cluster/trustedclusters/

One thing we had to do weird to get it working was having 8443 on pfSense redirect to Teleport without haproxy. Likely how Teleport combines proxing multiple protocols over the https web port which haproxy does not fully transfer, same issue when running tsh from laptops.
