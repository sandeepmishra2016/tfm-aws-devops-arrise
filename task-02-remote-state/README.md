# Task 2: Remote State

This directory is split into two pieces:

- `bootstrap/` creates the state bucket and lock table.
- `backend.tf.example` and `backend.hcl.example` show how another stack consumes them.

Bootstrapping is separate because a backend cannot use an S3 bucket before that bucket exists. The bucket is encrypted, versioned, blocked from public access and protected by a TLS-only policy. DynamoDB uses on-demand billing because lock traffic is small and irregular.

S3 versioning and locking solve different failures. Versioning can recover an overwritten state object; locking prevents two writers from changing the same state concurrently.

```bash
terraform -chdir=bootstrap init -backend=false
terraform -chdir=bootstrap validate
terraform -chdir=bootstrap test
```

DynamoDB locking is retained because it is part of the assignment. For a new backend on a compatible Terraform release, I would assess S3 native locking with `use_lockfile = true`.
