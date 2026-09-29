locals {
  protected_instances = {
    for name, config in var.instances : name => config
    if name == var.protected_instance_name
  }

  standard_instances = {
    for name, config in var.instances : name => config
    if name != var.protected_instance_name
  }

  common_tags = {
    Environment = var.environment
    Owner       = var.owner
  }
}

