data "aws_iam_policy_document" "ci" {
  statement {
    sid       = "AuthenticateToECR"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PushToNamedECRRepository"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [local.ecr_repository_arn]
  }

  statement {
    sid    = "RegisterAndInspectTaskDefinitions"
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DeployOnlyNamedECSService"
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]
    resources = [local.ecs_service_arn]
  }

  statement {
    sid       = "InspectNamedECSCluster"
    effect    = "Allow"
    actions   = ["ecs:DescribeClusters"]
    resources = [local.ecs_cluster_arn]
  }

  statement {
    sid     = "PassOnlyApprovedECSTaskRoles"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      local.task_role_arn,
      local.execution_role_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    sid       = "ListArtifactBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.artifact_bucket_arn]
  }

  statement {
    sid       = "ReadArtifacts"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${local.artifact_bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "ci" {
  name        = "arrise-ci-deployment"
  description = "Least-privilege ECR push, ECS deploy, and S3 artifact-read policy."
  policy      = data.aws_iam_policy_document.ci.json
}

resource "aws_iam_user_policy_attachment" "ci" {
  count = var.attach_to_ci_user ? 1 : 0

  user       = var.ci_user_name
  policy_arn = aws_iam_policy.ci.arn
}

