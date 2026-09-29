# Implementation Notes

## Task 1

I used a map of typed objects and `for_each` because the instance name is the resource identity. Adding or removing one map entry does not shift positional indexes and replace unrelated instances, which can happen with `count`.

The protected instance is `management`. Terraform lifecycle settings are evaluated before ordinary expressions, so `prevent_destroy` cannot be calculated from `each.key` or an input property. A single resource block would protect all five instances. I therefore split the same input map into two filtered collections: one protected instance and four standard instances. This keeps the configuration variable-driven without pretending that Terraform supports a dynamic lifecycle argument.

Deletion protection reduces accidental Terraform destruction; it is not a backup or disaster-recovery mechanism. A deliberate retirement requires removing `prevent_destroy`, reviewing the plan, and applying that configuration change before destroying the instance.

## Task 2

With local state, two engineers can each have a different view of the infrastructure. Both can create plans from stale state and attempt conflicting changes. There is no shared lock and no authoritative state object.

The S3 backend provides one remote state object. Locking prevents concurrent state-changing operations, while S3 versioning provides a recovery path if the state object is overwritten. Encryption, public-access blocking, TLS enforcement, and narrow IAM access protect a file that may contain sensitive infrastructure attributes.

The backend is bootstrapped separately because Terraform cannot use an S3 bucket before it exists. The assignment asks for DynamoDB locking, so the solution includes it. Current Terraform also supports S3 lockfiles through `use_lockfile = true`, while DynamoDB-based locking is deprecated. For a new platform I would use S3 native locking after confirming the organization's Terraform version; here I retain DynamoDB to meet the stated requirement.

## Task 3

I would not issue long-lived IAM user access keys to people or CI workloads in production. Human access should normally use IAM Identity Center or federated SSO with short-lived role sessions. CI should use workload identity such as GitHub OIDC, a Jenkins instance role, or another trusted OIDC provider. Long-lived keys increase secret-distribution, rotation, and exfiltration risk.

The assignment asks for CLI-only and console-plus-CLI users, so the users and groups are represented. Legacy credentials are an explicit opt-in and require PGP encryption. They are disabled by default so a normal apply does not create durable credentials or plaintext secrets in Terraform state.

Trusting Account A root in roleC does not mean only the root user can assume the role. It delegates trust to Account A, after which other Account A principals may be allowed by their identity policies. Trusting roleB's exact ARN constrains the principal boundary to roleB. roleB separately receives only one permission: `sts:AssumeRole` on roleC.

roleA follows the assignment literally: allow administrative actions and explicitly deny `iam:*`. The deny wins over the broad allow. This remains a high-risk role. In production I would also restrict who can assume it, require federation and MFA, monitor sessions, and use organization-level guardrails where appropriate.

## Task 4

The CI policy is built from the required operations instead of starting with a broad managed policy.

Deliberately excluded permissions include IAM administration, unrestricted `iam:PassRole`, ECR repository administration, ECS cluster or service deletion, S3 writes and deletes, access to unrelated buckets, and general account administration.

Two statements use `Resource = "*"` because of AWS authorization behavior, not convenience:

- `ecr:GetAuthorizationToken` does not support repository-level resource scoping.
- `ecs:RegisterTaskDefinition` creates a new revision that does not yet have an ARN to authorize against.

`iam:PassRole` is limited to the exact task and execution role ARNs and constrained to the ECS tasks service. `ecs:UpdateService`, ECR upload operations, and S3 reads are scoped to their named resources.

## Task 5

The trust policy fails because it identifies roleB using a user ARN:

```text
arn:aws:iam::000000000000:user/roleB
```

roleB is a role, so roleC must trust:

```text
arn:aws:iam::000000000000:role/roleB
```

The second problem is `s3:*` on `*`, which allows access outside the required bucket. The corrected policy scopes access to the named bucket ARN and its object ARN.

Correcting roleC alone is not enough for a successful request. roleB also needs an identity policy allowing `sts:AssumeRole` on roleC. The final solution includes both sides of that authorization relationship.

