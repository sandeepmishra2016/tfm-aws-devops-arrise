variable "aws_region" {
  description = "AWS Region containing the CI deployment targets."
  type        = string
  default     = "ap-south-1"
}

variable "aws_account_id" {
  description = "AWS account containing ECR, ECS, IAM roles, and the artifact bucket."
  type        = string
  default     = "000000000000"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must contain exactly 12 digits."
  }
}

variable "ecr_repository_name" {
  description = "Only ECR repository to which CI may push."
  type        = string
  default     = "arrise-application"
}

variable "ecs_cluster_name" {
  description = "ECS cluster containing the deployment target."
  type        = string
  default     = "arrise-cluster"
}

variable "ecs_service_name" {
  description = "Only ECS service CI may update."
  type        = string
  default     = "arrise-service"
}

variable "ecs_task_role_name" {
  description = "Existing ECS application task role CI may pass."
  type        = string
  default     = "arrise-ecs-task-role"
}

variable "ecs_execution_role_name" {
  description = "Existing ECS execution role CI may pass."
  type        = string
  default     = "arrise-ecs-execution-role"
}

variable "artifact_bucket_name" {
  description = "Only S3 bucket from which CI may read artifacts."
  type        = string
  default     = "replace-with-build-artifact-bucket"
}
