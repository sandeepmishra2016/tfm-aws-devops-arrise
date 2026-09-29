# Assumptions

1. Account IDs `000000000000` and `111111111111` are placeholders from the assignment and are supplied as variables before deployment.
2. The EC2 AMI, subnet, security groups, and key pairs already exist. The assignment is about fleet modelling rather than VPC or key generation.
3. EC2 workloads run in a private subnet and do not require public IP addresses.
4. The `management` instance is the single resource protected from accidental destruction.
5. Group names describe the requested authentication modes, not direct application authorization. To make the access paths functional without inventing unrelated service permissions, group1 may assume roleB and group2 may assume roleA.
6. The two console-capable users are `operations-admin-1` and `operations-admin-2`.
7. The CLI users `engine` and `ci` are the initial trusted principals allowed to assume roleB. This closes an otherwise unspecified trust-policy requirement without trusting the entire account.
8. roleC and the named S3 bucket belong to Account B. Therefore, an identity policy on roleC is sufficient unless the bucket has an additional restrictive bucket policy or KMS key policy.
9. The ECR repository, ECS cluster and service, ECS task roles, and build-artifact bucket already exist before the Task 4 policy is attached.
10. Terraform execution uses an authorized sandbox. This repository does not contain live credentials or account-specific backend configuration.
