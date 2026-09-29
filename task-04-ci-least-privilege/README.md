# Task 4 Least Privilege CI Policy

## Approach

I built the policy from the pipeline operations instead of attaching a managed policy and trying to explain the excess permissions afterward.

The policy grants four narrow capabilities:

1. Authenticate to ECR and push to one repository.
2. Register a new ECS task-definition revision.
3. Update and inspect one ECS service.
4. Read artifacts from one S3 bucket.

`iam:PassRole` is included because ECS task definitions commonly reference task and execution roles. It is limited to those exact ARNs and only when passed to `ecs-tasks.amazonaws.com`.

## Necessary Wildcards

- `ecr:GetAuthorizationToken` does not support repository-level resources.
- `ecs:RegisterTaskDefinition` creates a resource, so it cannot be restricted to a task-definition revision that does not yet exist.

Other operations are scoped to named resources. The policy does not permit S3 writes, IAM administration, repository deletion, ECS service deletion, or unrestricted role passing.

## Validate and Inspect

```bash
terraform init -backend=false
terraform fmt -check
terraform validate
terraform console
```

Inside the console:

```hcl
jsondecode(data.aws_iam_policy_document.ci.json)
```

`generated-policy-example.json` shows the expected rendered structure using the assignment's placeholder account.

