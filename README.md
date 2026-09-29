# ARRISE DevOps Assignment

This repository contains one small Terraform root for each assignment task. I kept the tasks independent so they can be initialized and reviewed without deploying unrelated resources.

| Task | Solution | Key choice |
|---|---|---|
| 1 | [`task-01-ec2-fleet`](task-01-ec2-fleet/) | `for_each` keeps instance addresses stable; the protected instance is separated because `prevent_destroy` cannot depend on `each.key` |
| 2 | [`task-02-remote-state`](task-02-remote-state/) | Bootstrap the S3 bucket and DynamoDB table before configuring the backend |
| 3 | [`task-03-cross-account-iam`](task-03-cross-account-iam/) | roleC trusts roleB's ARN directly, and roleB can assume only roleC |
| 4 | [`task-04-ci-least-privilege`](task-04-ci-least-privilege/) | CI permissions are scoped to one ECR repository, ECS service, artifact bucket and two task roles |
| 5 | [`task-05-bug-fix`](task-05-bug-fix/) | Replace the incorrect user ARN with roleB's role ARN and limit S3 access to the named bucket |

## Validate

Terraform 1.10.5 is used in CI. The workflow runs formatting and `terraform validate` for all five roots without AWS credentials.

```bash
make fmt
make validate
```

## Deployment Notes

- Replace the placeholder account IDs and resource names before planning.
- Task 1 expects an existing AMI, private subnet, security groups and key pairs.
- Apply Task 2's bootstrap stack before enabling the example S3 backend.
- Task 3 requires credentials authorized independently for Accounts A and B.
- Task 4 assumes the ECR repository, ECS service, task roles and artifact bucket already exist.
- No live AWS apply is included. Validation here checks Terraform configuration, not external SCPs, KMS policies or existing resource policies.

The assumptions used for unspecified inputs are listed in [`ASSUMPTIONS.md`](ASSUMPTIONS.md).
