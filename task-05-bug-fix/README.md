# Task 5 Find and Fix the Bug

## What Was Broken

### Trust policy

The supplied principal is a user ARN:

```text
arn:aws:iam::000000000000:user/roleB
```

roleB is an IAM role, so roleC must trust its role ARN:

```text
arn:aws:iam::000000000000:role/roleB
```

I trust that exact ARN rather than Account A root because the requirement permits only roleB to assume roleC.

### Permissions policy

The supplied policy grants `s3:*` on `*`, allowing roleC to operate outside the named bucket. The corrected policy retains the requested full S3 capability but limits resources to:

```text
arn:aws:s3:::named-bucket
arn:aws:s3:::named-bucket/*
```

## Complete Authorization Path

A correct roleC trust policy is necessary but not sufficient. roleB also needs an identity policy permitting `sts:AssumeRole` on roleC. `fixed-role-c.tf` includes both policy documents so the complete relationship is visible to the reviewer.

```text
roleB identity policy -> allows AssumeRole on roleC
roleC trust policy    -> trusts exact roleB ARN
roleC permissions     -> permits S3 access only in named bucket
```

## Validate

```bash
terraform init -backend=false
terraform fmt -check
terraform validate
```

The original code is retained as `broken-snippet.tf.txt`; the `.txt` suffix prevents Terraform from loading intentionally invalid code.

