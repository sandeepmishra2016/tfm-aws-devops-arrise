# Design Notes

These are the decisions that are not obvious from the resource blocks.

## EC2 fleet

The instance name is the `for_each` key, so adding an instance does not renumber or replace unrelated instances as it could with `count`.

`prevent_destroy` cannot use `each.key`; Terraform evaluates lifecycle settings before normal expressions. I split the input into protected and standard maps so only `management` receives that lifecycle rule. Retirement still requires an intentional configuration change. This is protection against an accidental Terraform destroy, not a backup strategy.

## Remote state

The backend resources live in a bootstrap stack because Terraform cannot store state in a bucket that does not exist yet. S3 versioning handles state recovery, while locking handles concurrent writers.

I retained DynamoDB locking because the assignment asks for it. For a new implementation on a compatible Terraform version, I would evaluate the S3 backend's native `use_lockfile` option because DynamoDB locking is deprecated.

## IAM

The assignment requires IAM users, including CLI access. I modelled those users but left durable credentials disabled by default. My production preference is IAM Identity Center for people and OIDC or instance roles for automation.

roleC trusts roleB's exact ARN. Trusting Account A root would delegate the decision back to every identity policy in Account A, which is wider than the stated requirement. roleB has one permission: assume roleC. roleC then scopes S3 access to one bucket and its objects.

roleA follows the requirement of administrative access with an explicit `iam:*` deny. The deny overrides the broad allow. I would additionally put this behind federation, MFA, monitored sessions and organization guardrails.

## CI policy

The policy starts from the pipeline calls: push one image, register a task-definition revision, update one ECS service, pass two approved roles and read one artifact bucket.

Two actions remain on `Resource = "*"`:

- `ecr:GetAuthorizationToken` has no repository-level resource scope.
- `ecs:RegisterTaskDefinition` creates a revision whose ARN does not exist before the call.

The policy excludes IAM administration, unrestricted `iam:PassRole`, S3 writes and deletion of ECR or ECS resources.

## Bug fix

The supplied trust policy used a user ARN for roleB, and the S3 policy used `s3:*` on `*`. The correction uses roleB's role ARN and limits S3 resources to the named bucket. roleB also needs its own identity policy allowing `sts:AssumeRole` on roleC; fixing only roleC would leave the request path incomplete.
