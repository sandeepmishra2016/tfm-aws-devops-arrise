# Solution Notes

## Task 1: EC2 Fleet

I modelled the five instances as a map of typed objects and created them with `for_each`. The map key is the instance identity, so adding or removing an entry does not renumber unrelated resources as `count` can.

The `management` instance needs `prevent_destroy`. Terraform lifecycle arguments cannot depend on `each.key`, so one dynamic resource block cannot protect only that instance. I split the same input map into protected and standard collections: one protected instance and four standard instances.

`prevent_destroy` protects against an accidental Terraform deletion; it is not a backup mechanism. Retiring the instance requires removing the lifecycle rule, reviewing that plan, and applying the change before destroying it.

## Task 2: Remote State

Local state gives each engineer a separate view of the infrastructure and provides no shared lock. The S3 backend provides one authoritative state object, while DynamoDB locking prevents concurrent state-changing operations. S3 versioning provides a recovery point if the state object is overwritten.

The state bucket enables encryption, versioning, and all four public-access-block settings. The DynamoDB table uses on-demand capacity and server-side encryption.

The backend resources are bootstrapped separately because Terraform cannot use a bucket before it exists. DynamoDB locking is retained because the assignment requests it. For a new implementation, I would check the organization's Terraform version and consider S3 native locking with `use_lockfile = true` because DynamoDB-based locking is deprecated.

## Task 3: Cross-Account IAM

The requested IAM users and group memberships are represented, but the configuration does not generate access keys or console passwords. For production, I would use IAM Identity Center or federated SSO for people and workload identity such as OIDC or an instance role for automation.

The access path is explicit:

```text
engine / ci -> roleB in Account A -> roleC in Account B -> named S3 bucket
```

roleB can call only `sts:AssumeRole` on roleC. roleC trusts roleB's exact ARN rather than Account A root, so the trust boundary cannot be expanded by granting another Account A principal an identity policy.

roleA follows the requirement of broad administrative access with an explicit deny on `iam:*`. The deny overrides the allow. Its trust policy also requires MFA. In production I would place additional controls around this high-privilege role, including federation, session monitoring, permission boundaries, and organization-level guardrails.

## Task 4: Least-Privilege CI Policy

I built the CI policy from the deployment operations instead of attaching a broad AWS-managed policy. It allows the pipeline to:

1. Authenticate to ECR and push to one repository.
2. Register and inspect ECS task definitions.
3. Update one ECS service.
4. Pass only the configured task and execution roles to ECS tasks.
5. Read artifacts from one S3 bucket.

Two actions require `Resource = "*"` because of AWS authorization behavior:

- `ecr:GetAuthorizationToken` does not support repository-level resource scoping.
- `ecs:RegisterTaskDefinition` creates a new revision whose ARN does not exist before the request.

ECR upload actions, ECS service updates, S3 reads, and `iam:PassRole` are scoped to named resources. The policy does not grant IAM administration, unrestricted role passing, S3 writes, or ECR/ECS deletion.

## Task 5: IAM Trust and Permission Fix

The supplied trust policy identifies roleB with a user ARN:

```text
arn:aws:iam::000000000000:user/roleB
```

Because roleB is an IAM role, roleC must trust its role ARN:

```text
arn:aws:iam::000000000000:role/roleB
```

The supplied permissions policy also grants `s3:*` on `*`. The corrected policy limits access to the named bucket ARN and `${bucket_arn}/*`.

The final configuration includes both sides of the authorization relationship: roleB's identity policy permits `sts:AssumeRole` on roleC, and roleC's trust policy accepts roleB. Fixing only one side would still leave the request path incomplete.
