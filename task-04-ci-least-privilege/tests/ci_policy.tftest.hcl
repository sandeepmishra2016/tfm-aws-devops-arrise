mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "plan_scoped_ci_policy" {
  command = plan

  assert {
    condition     = local.ecr_repository_arn == "arn:aws:ecr:ap-south-1:000000000000:repository/arrise-application"
    error_message = "ECR writes must target one repository."
  }

  assert {
    condition     = local.ecs_service_arn == "arn:aws:ecs:ap-south-1:000000000000:service/arrise-cluster/arrise-service"
    error_message = "ECS deployment must target one named service."
  }

  assert {
    condition     = local.artifact_bucket_arn == "arn:aws:s3:::replace-with-build-artifact-bucket"
    error_message = "Artifact reads must target one named bucket."
  }

  assert {
    condition     = length(aws_iam_user_policy_attachment.ci) == 0
    error_message = "The standalone policy review must not attach to a real user by default."
  }

  assert {
    condition = toset([
      local.task_role_arn,
      local.execution_role_arn
      ]) == toset([
      "arn:aws:iam::000000000000:role/arrise-ecs-task-role",
      "arn:aws:iam::000000000000:role/arrise-ecs-execution-role"
    ])
    error_message = "iam:PassRole scope must contain only the approved ECS task roles."
  }
}
