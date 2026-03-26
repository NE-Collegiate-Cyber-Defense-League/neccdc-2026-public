# Regionals 2026 Blue Team Terraform

## Usage

### Initializing the Workspace
To initialize a new workspace for a team, use the following commands:

```bash
terraform workspace new -or-create [team_number] 
```

### Applying the Configuration

To apply the Terraform configuration, simply run:
```bash
terraform apply
```

```bash
for i in {1..10}; do
  terraform workspace select -or-create $i
  terraform apply -auto-approve
done
```
