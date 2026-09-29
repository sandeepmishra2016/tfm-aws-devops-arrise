resource "aws_instance" "standard" {
  for_each = local.standard_instances

  ami                         = var.ami_id
  instance_type               = each.value.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = each.value.key_name
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted             = true
    delete_on_termination = true
    volume_type           = each.value.root_volume_type
    volume_size           = each.value.root_volume_size_gib
    iops                  = contains(["gp3", "io1", "io2"], each.value.root_volume_type) ? try(each.value.root_volume_iops, null) : null
    throughput            = each.value.root_volume_type == "gp3" ? try(each.value.root_volume_throughput, null) : null

    tags = merge(local.common_tags, {
      Name = "${each.key}-root"
    })
  }

  tags = merge(local.common_tags, {
    Name = each.key
  })
}

resource "aws_instance" "protected" {
  for_each = local.protected_instances

  ami                         = var.ami_id
  instance_type               = each.value.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = each.value.key_name
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted             = true
    delete_on_termination = true
    volume_type           = each.value.root_volume_type
    volume_size           = each.value.root_volume_size_gib
    iops                  = contains(["gp3", "io1", "io2"], each.value.root_volume_type) ? try(each.value.root_volume_iops, null) : null
    throughput            = each.value.root_volume_type == "gp3" ? try(each.value.root_volume_throughput, null) : null

    tags = merge(local.common_tags, {
      Name = "${each.key}-root"
    })
  }

  tags = merge(local.common_tags, {
    Name = each.key
  })

  lifecycle {
    prevent_destroy = true
  }
}

