## Setup

```bash
docker network create --ipv6 --ipv4 --driver bridge neccdc-devcontainer
```


## Troubleshooting

Sometimes when rebuilding the container the ansible collections don't get pulled. Reimport them as a sanity check

```bash
ansible-galaxy install -r /tmp/requirements.yaml
```
