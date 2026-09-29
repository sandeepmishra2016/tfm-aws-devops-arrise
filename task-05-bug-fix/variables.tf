variable "aws_region" {
  description = "AWS Region used by the provider."
  type        = string
  default     = "ap-south-1"
}

variable "account_a_id" {
  description = "Account A ID containing roleB."
  type        = string
  default     = "000000000000"
}

variable "account_b_id" {
  description = "Account B ID containing roleC."
  type        = string
  default     = "111111111111"
}

variable "role_b_name" {
  description = "Source role in Account A."
  type        = string
  default     = "roleB"
}

variable "role_c_name" {
  description = "Target role in Account B."
  type        = string
  default     = "roleC"
}

variable "bucket_name" {
  description = "Only S3 bucket roleC may access."
  type        = string
  default     = "replace-with-account-b-bucket"
}

