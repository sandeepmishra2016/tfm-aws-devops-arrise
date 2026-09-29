# Task 5: IAM Bug Fix

The supplied trust policy names roleB as a user:

```text
arn:aws:iam::000000000000:user/roleB
```

roleC must instead trust the role ARN:

```text
arn:aws:iam::000000000000:role/roleB
```

The original permissions also grant `s3:*` on every S3 resource. The corrected policy limits the resource list to the named bucket ARN and `${bucket_arn}/*`.

There are two authorization checks in an STS role assumption: roleB needs an identity policy allowing `sts:AssumeRole` on roleC, and roleC needs a trust policy accepting roleB. `fixed-role-c.tf` contains both documents.

```bash
terraform init -backend=false
terraform validate
terraform test
```

The supplied code remains in `broken-snippet.tf.txt` for comparison. The `.txt` suffix keeps Terraform from loading it.
