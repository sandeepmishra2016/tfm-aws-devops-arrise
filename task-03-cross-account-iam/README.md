# Task 3: Cross-Account IAM

The two AWS accounts are represented by aliased providers. A real apply requires a separately authorized session for each provider.

```text
engine / ci
  -> roleB in Account A
  -> roleC in Account B
  -> named S3 bucket in Account B
```

roleB can assume only roleC. roleC trusts roleB's ARN directly and grants S3 access only to the configured bucket and its objects. The second group can assume roleA, which follows the requested administrative-access-except-IAM rule.

IAM users and group membership are created because the assignment asks for them. Access keys and console passwords are disabled by default. Enabling legacy credentials requires a PGP key for every user so secret material is not written to output or state in plaintext.

```bash
terraform init -backend=false
terraform validate
terraform test
```

The account IDs in `terraform.tfvars.example` are placeholders. In production I would use IAM Identity Center for human access and workload identity for CI instead of durable IAM credentials.
