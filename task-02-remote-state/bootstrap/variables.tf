variable "aws_region" {
  description = "AWS Region for state infrastructure."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking."
  type        = string
  default     = "arrise-terraform-state-locks"
}

