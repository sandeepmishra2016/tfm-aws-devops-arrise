# Task 3 Multi Account IAM and Cross Account Access

## Approach

This task models both accounts in one reviewable Terraform root using aliased AWS providers. In a real deployment, each provider would authenticate to its account through an approved SSO or administrative role session.

The authorization path is intentionally narrow:

```text
engine or ci
  -> assumes Account A roleB
  -> roleB may only assume Account B roleC
  -> roleC trusts only roleB
  -> roleC can access only the named Account B bucket
```

## Requirement Mapping

| Requirement | Implementation |
|---|---|
| group1 with `engine` and `ci` | `account-a-users.tf` |
| group2 with two named users | `operations-admin-1` and `operations-admin-2` |
| Make groups operational | group1 may assume roleB; group2 may assume roleA |
| roleA admin except IAM | Broad allow plus explicit `iam:*` deny |
| roleB only assumes roleC | One `sts:AssumeRole` statement for roleC ARN |
| roleC trusts only roleB | Exact Account A role ARN in trust policy |
| roleC accesses one bucket | `s3:*` scoped to bucket and object ARNs |

## Credential Decision

Users and memberships are created, but durable credentials are disabled by default. Setting `create_legacy_credentials = true` requires a PGP key for every user, so Terraform stores only encrypted secret material in its outputs and state.

For production I would keep this option disabled and use IAM Identity Center for people and OIDC or instance/workload roles for automation.

## Validate

```bash
terraform init -backend=false
terraform fmt -check
terraform validate
```

The account IDs in the example are placeholders from the assignment. A real plan requires valid credentials for both provider aliases and real account IDs.
