# maverick-infrastructure

## Terraform commands

Initialization:

```
terraform init \
  -backend-config="bucket=terraform-state" \
  -backend-config="dynamodb_table=terraform-state-lock" \
  -backend-config="region=ca-central-1"
```

Plan

```
terraform plan
```

Apply

```
terraform apply
```
