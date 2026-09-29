output "instance_ids" {
  description = "Map of stable instance names to EC2 instance IDs."
  value = merge(
    { for name, instance in aws_instance.standard : name => instance.id },
    { for name, instance in aws_instance.protected : name => instance.id }
  )
}

output "instance_private_ips" {
  description = "Map of stable instance names to private IP addresses."
  value = merge(
    { for name, instance in aws_instance.standard : name => instance.private_ip },
    { for name, instance in aws_instance.protected : name => instance.private_ip }
  )
}

