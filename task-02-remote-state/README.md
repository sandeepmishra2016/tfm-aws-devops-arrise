# Task 2 Remote State and Locking

## Approach

Backend resources must exist before Terraform can use them, so this task has a small bootstrap stack. It creates an encrypted and versioned S3 bucket, blocks public access, denies non-TLS requests, and creates the requested DynamoDB lock table.

After bootstrap, `backend.tf.example` and `backend.hcl.example` show how another stack consumes the backend without committing real environment values.

## Why Local State Is Unsafe for a Team

Two engineers using local state have separate views and no shared lock. Both can plan from stale information and race to change the same resources. Remote state gives the team one authoritative object; locking ensures only one state-changing operation proceeds at a time.

Locking protects concurrency. S3 versioning provides recovery from accidental state replacement. They solve different problems, so both are enabled.

## Validate

```bash
terraform -chdir=bootstrap init -backend=false
terraform -chdir=bootstrap fmt -check
terraform -chdir=bootstrap validate
```

The assignment explicitly requests DynamoDB locking. It is implemented here even though newer Terraform versions prefer S3 native lockfiles with `use_lockfile = true`.

