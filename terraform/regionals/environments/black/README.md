# Qualifiers Black Team Terraform

## Usage

### Creation
```bash
terraform apply
```

If you get the error message `InvalidParameterValue` when trying to create the VPC. This is likely due to the VPC being recently removed and the allocation has not been cleared in IPAM.

You're just going to have to wait until aws is ready.
This command will list if the ipv6 range is still allocated, when it does not return anything its ready
```bash
watch aws ec2 get-ipam-pool-allocations --ipam-pool-id ipam-pool-0ae6e3ca75b637cdd
```


### Deletion
The vpc deletion will hang, so just ctrl+c and rerun the destroy
```bash
terraform destroy
```

## Ipv6 Breakdown
pub block = 2600:1f26:1d:8000::/52

internal = 2600:1f26:001d:8000::/56 (vpn, etc.)
first = 2600:1f26:001d:8a00::/56
second = 2600:1f26:001d:8b00::/56
third = 2600:1f26:001d:8c00::/56

Team subnets will be out of 64 in that range (ie `2600:1f26:001d:8a0X::/64`)
