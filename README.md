# ARRISE DevOps Assignment

My solution is split by task so each part can be reviewed and tested independently.

| Task | Implementation | Main decision |
|---|---|---|
| 1 | [`task-01-ec2-fleet`](task-01-ec2-fleet/) | Use stable `for_each` keys and isolate the one instance that needs `prevent_destroy` |
| 2 | [`task-02-remote-state`](task-02-remote-state/) | Bootstrap S3 and DynamoDB before configuring the backend |
| 3 | [`task-03-cross-account-iam`](task-03-cross-account-iam/) | Trust roleB's ARN directly instead of trusting the whole source account |
| 4 | [`task-04-ci-least-privilege`](task-04-ci-least-privilege/) | Build the CI policy from required API calls and scope each resource where AWS permits it |
| 5 | [`task-05-bug-fix`](task-05-bug-fix/) | Correct both sides of the roleB-to-roleC authorization path |

## Repository Layout

```text
task-01-ec2-fleet/          EC2 fleet driven by one typed input map
task-02-remote-state/       S3 state bucket and DynamoDB locking
task-03-cross-account-iam/  IAM users, groups and cross-account roles
task-04-ci-least-privilege/ ECR, ECS and S3 permissions for CI
task-05-bug-fix/            Corrected trust and S3 policies
```

[`ASSUMPTIONS.md`](ASSUMPTIONS.md) records the inputs that were unclear or outside the assignment. [`NOTES.md`](NOTES.md) explains the decisions that are easy to miss by reading Terraform alone.

## Validation

The repository is checked with Terraform 1.10.5 in GitHub Actions. The workflow runs formatting, initialization, validation and mocked Terraform tests for each task.

```bash
make fmt-check
make validate
make test
```

The latest recorded result and the limits of the mocked tests are in [`VALIDATION.md`](VALIDATION.md).

## Applying in AWS

The examples contain placeholder account IDs and resource names. A sandbox deployment would use this order:

1. Apply `task-02-remote-state/bootstrap`.
2. Put the output values in an uncommitted `backend.hcl`.
3. Run `terraform init -backend-config=backend.hcl` for the state-consuming stack.
4. Apply Task 1 with existing subnet, security-group, AMI and key-pair IDs.
5. Run Task 3 with independently authorized sessions for Accounts A and B.
6. Apply Task 4 only after its ECR repository, ECS service, task roles and artifact bucket exist.

Task 5 is the isolated correction requested in the assignment; Task 3 contains the same corrected relationship in the complete IAM model.

## Security Choices

- EC2 instances are private, root volumes are encrypted, and IMDSv2 is required.
- State storage has encryption, versioning, public-access blocking and a TLS-only bucket policy.
- Cross-account access trusts a named role ARN.
- CI can pass only the two approved ECS roles and access only the named ECR, ECS and S3 resources.
- Long-lived IAM credentials are disabled unless explicitly enabled with PGP encryption.
- State, plans, credentials and populated variable files are excluded from Git.

## References

- [Terraform lifecycle](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)
- [Terraform S3 backend](https://developer.hashicorp.com/terraform/language/backend/s3)
- [AWS cross-account IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html)
- [Amazon ECR push permissions](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-push-iam.html)
