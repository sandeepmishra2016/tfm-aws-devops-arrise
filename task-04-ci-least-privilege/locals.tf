locals {
  ecr_repository_arn  = "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.ecr_repository_name}"
  ecs_cluster_arn     = "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:cluster/${var.ecs_cluster_name}"
  ecs_service_arn     = "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  task_role_arn       = "arn:aws:iam::${var.aws_account_id}:role/${var.ecs_task_role_name}"
  execution_role_arn  = "arn:aws:iam::${var.aws_account_id}:role/${var.ecs_execution_role_name}"
  artifact_bucket_arn = "arn:aws:s3:::${var.artifact_bucket_name}"
}
