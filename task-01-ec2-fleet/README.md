# Task 1 Multi Instance EC2 Provisioning

## Approach

All five instances are supplied through one `map(object(...))`. I use `for_each` so names remain stable Terraform addresses and one configuration change does not renumber unrelated resources.

Terraform does not allow `prevent_destroy` to depend on `each.key`. To protect only `management`, the same input map is filtered into protected and standard collections. This produces two resource blocks, not five hardcoded blocks, and applies deletion protection to exactly one instance.

## Requirement Mapping

| Requirement | Implementation |
|---|---|
| Five instances from one variable | `var.instances` with an exact-size validation |
| Different compute and storage | Per-instance typed object values |
| At least one io1 or io2 volume | Terraform check plus `database` example using `io2` |
| Required tags | Common tags merged with `Name` |
| Protect one instance | Filtered `aws_instance.protected` resource |
| ID and private-IP maps | Merged `for` expression outputs |

## Validate

```bash
terraform init -backend=false
terraform fmt -check
terraform validate
```

To generate a real plan, copy the example variables, replace placeholder resource IDs, and use an authorized sandbox:

```bash
cp terraform.tfvars.example terraform.tfvars
terraform plan -out=task-01.tfplan
```

The example keeps instances private, encrypts root volumes, and requires IMDSv2. Existing key-pair names are accepted as inputs; Terraform does not create or store private keys.

