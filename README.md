# ARRISE DevOps Assignment

This repository contains my solution to the five-part DevOps assignment. I organized it by task because the reviewer should be able to open one folder, compare the requirement with the implementation, and validate it without tracing files across an oversized Terraform codebase.

The code is deliberately conservative. It uses stable Terraform keys, encrypted storage, exact IAM principals, narrowly scoped permissions, and no committed credentials or state. Where the assignment conflicts with Terraform behavior or leaves an authorization decision unspecified, I call that out rather than hiding it behind code.

## Reviewer Index

| Task | Area | Implementation | Validation |
|---|---|---|---|
| 1 | Variable-driven EC2 fleet | [`task-01-ec2-fleet`](task-01-ec2-fleet/) | `make validate-task-1` |
| 2 | Remote state and locking | [`task-02-remote-state`](task-02-remote-state/) | `make validate-task-2` |
| 3 | Cross-account IAM | [`task-03-cross-account-iam`](task-03-cross-account-iam/) | `make validate-task-3` |
| 4 | Least-privilege CI policy | [`task-04-ci-least-privilege`](task-04-ci-least-privilege/) | `make validate-task-4` |
| 5 | Trust and permission bug fix | [`task-05-bug-fix`](task-05-bug-fix/) | `make validate-task-5` |

## Design Summary

```text
Task 1                         Task 2
One instance input map        Bootstrap state infrastructure once
  -> filtered for_each          -> encrypted/versioned S3 bucket
  -> four standard EC2          -> DynamoDB lock table
  -> one protected EC2          -> backend consumed by main stacks

Task 3
Account A principal
  -> assumes roleB
  -> roleB may only call sts:AssumeRole on roleC
  -> Account B roleC trusts roleB's exact ARN
  -> roleC can operate only on the named S3 bucket

Task 4
CI identity
  -> authenticate and push to one ECR repository
  -> register a task definition and update one ECS service
  -> pass only the approved ECS task roles
  -> read only from one artifact bucket
```

## Validation

Prerequisites:

- Terraform 1.5 or later
- AWS provider download access
- `make`
- Optional: TFLint

Run all static checks without deploying AWS resources:

```bash
make fmt-check
make validate
make test
```

Optional linting:

```bash
make lint
```

No AWS credentials are required for these checks. The Terraform tests use mocked AWS providers to exercise plans and assertions without creating resources. A real plan or apply requires authorized sandbox accounts and environment-specific variable values.

## Deployment Order

If this were deployed in a sandbox:

1. Apply `task-02-remote-state/bootstrap` once.
2. Copy the resulting bucket and table names into a backend configuration file that is not committed.
3. Initialize the state-consuming stack with `terraform init -backend-config=backend.hcl`.
4. Apply Task 1 in the workload account.
5. Apply Account A and Account B portions of Task 3 using separately authorized provider sessions.
6. Apply Task 4 only after the target ECR repository, ECS service, task roles, and artifact bucket exist.

Task 5 is a focused correction of the supplied broken snippet and intentionally overlaps with the final Task 3 design.

## Security Boundaries

- No state files, plans, credentials, private keys, or populated variable files are committed.
- EC2 instances have encrypted root volumes, IMDSv2 enforcement, and no public IP by default.
- Terraform state is encrypted, versioned, blocked from public access, and protected against non-TLS requests.
- Cross-account trust names the exact role ARN rather than trusting the whole source account.
- CI permissions are separated by capability and scoped to specific resource ARNs whenever AWS supports resource-level authorization.
- Legacy IAM credentials are disabled by default. An opt-in, PGP-encrypted example is included only to represent the assignment's requested access modes.

## Additional Notes

- [`NOTES.md`](NOTES.md) answers the written questions from the assignment.
- [`ASSUMPTIONS.md`](ASSUMPTIONS.md) records decisions for requirements that are not fully specified.

## Official References

- [Terraform lifecycle meta-argument](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)
- [Terraform S3 backend](https://developer.hashicorp.com/terraform/language/backend/s3)
- [AWS cross-account IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html)
- [Amazon ECR repository policies and IAM permissions](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-push-iam.html)
