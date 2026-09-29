variable "aws_region" {
  description = "AWS Region in which the instances are provisioned."
  type        = string
}

variable "ami_id" {
  description = "Existing AMI ID approved for this environment."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", var.ami_id))
    error_message = "ami_id must look like an AWS AMI ID."
  }
}

variable "subnet_id" {
  description = "Private subnet used by the EC2 fleet."
  type        = string
}

variable "security_group_ids" {
  description = "Existing security groups attached to each instance."
  type        = set(string)
}

variable "environment" {
  description = "Deployment environment added to every instance."
  type        = string
}

variable "owner" {
  description = "Owning team added to every instance."
  type        = string
}

variable "protected_instance_name" {
  description = "Name of the single instance protected with prevent_destroy."
  type        = string
  default     = "management"
}

variable "instances" {
  description = "Exactly five named EC2 instance configurations."

  type = map(object({
    instance_type          = string
    root_volume_type       = string
    root_volume_size_gib   = number
    root_volume_iops       = optional(number)
    root_volume_throughput = optional(number)
    key_name               = string
  }))

  validation {
    condition     = length(var.instances) == 5
    error_message = "Exactly five instance configurations must be supplied."
  }

  validation {
    condition = alltrue([
      for instance in values(var.instances) :
      contains(["gp2", "gp3", "io1", "io2"], instance.root_volume_type)
    ])
    error_message = "root_volume_type must be gp2, gp3, io1, or io2."
  }

  validation {
    condition = alltrue([
      for instance in values(var.instances) : instance.root_volume_size_gib >= 8
    ])
    error_message = "Every root volume must be at least 8 GiB."
  }

  validation {
    condition = alltrue([
      for instance in values(var.instances) :
      !contains(["io1", "io2"], instance.root_volume_type) || coalesce(try(instance.root_volume_iops, null), 0) > 0
    ])
    error_message = "io1 and io2 volumes require a positive root_volume_iops value."
  }
}

check "protected_instance_exists" {
  assert {
    condition     = contains(keys(var.instances), var.protected_instance_name)
    error_message = "protected_instance_name must match one key in var.instances."
  }
}

check "one_provisioned_iops_volume" {
  assert {
    condition = anytrue([
      for instance in values(var.instances) : contains(["io1", "io2"], instance.root_volume_type)
    ])
    error_message = "At least one instance must use io1 or io2 storage."
  }
}
