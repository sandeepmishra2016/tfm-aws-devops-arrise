# Task 1: EC2 Fleet

`var.instances` is one typed map containing all five instance definitions. I used `for_each` because the map key gives every instance a stable Terraform address.

The only awkward part is deletion protection. Terraform does not allow this:

```hcl
prevent_destroy = each.key == "management"
```

Lifecycle arguments must be known before normal expression evaluation. I therefore filter the input into `standard_instances` and `protected_instances`. Both resources use the same input shape, but only the protected resource has `prevent_destroy = true`.

The configuration also checks that exactly five instances are supplied, at least one uses `io1` or `io2`, and provisioned-IOPS volumes include an IOPS value. Instances use private addresses, encrypted root volumes and IMDSv2.

```bash
terraform init -backend=false
terraform fmt -check
terraform validate
terraform test
```

For an AWS plan, copy `terraform.tfvars.example`, replace the placeholder AMI, subnet and security-group IDs, and use sandbox credentials.
