variable "aws_region" {
  description = "AWS Region used by both provider configurations."
  type        = string
  default     = "ap-south-1"
}

variable "account_a_id" {
  description = "Twelve-digit Account A ID."
  type        = string
  default     = "000000000000"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_a_id))
    error_message = "account_a_id must contain exactly 12 digits."
  }
}

variable "account_b_id" {
  description = "Twelve-digit Account B ID."
  type        = string
  default     = "111111111111"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_b_id))
    error_message = "account_b_id must contain exactly 12 digits."
  }
}

variable "account_a_profile" {
  description = "Optional local AWS profile authorized for Account A."
  type        = string
  default     = null
}

variable "account_b_profile" {
  description = "Optional local AWS profile authorized for Account B."
  type        = string
  default     = null
}

variable "role_a_name" {
  description = "Administrative role name in Account A."
  type        = string
  default     = "roleA"
}

variable "role_b_name" {
  description = "Cross-account source role name in Account A."
  type        = string
  default     = "roleB"
}

variable "role_c_name" {
  description = "S3 access role name in Account B."
  type        = string
  default     = "roleC"
}

variable "account_b_bucket_name" {
  description = "Only S3 bucket roleC may access."
  type        = string
  default     = "replace-with-account-b-bucket"
}
