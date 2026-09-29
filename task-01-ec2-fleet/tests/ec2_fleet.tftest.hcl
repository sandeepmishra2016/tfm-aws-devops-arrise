mock_provider "aws" {}

variables {
  aws_region              = "ap-south-1"
  ami_id                  = "ami-0123456789abcdef0"
  subnet_id               = "subnet-0123456789abcdef0"
  security_group_ids      = ["sg-0123456789abcdef0"]
  environment             = "test"
  owner                   = "platform-engineering"
  protected_instance_name = "management"

  instances = {
    web = {
      instance_type        = "t3.small"
      root_volume_type     = "gp3"
      root_volume_size_gib = 20
      root_volume_iops     = 3000
      key_name             = "web-test"
    }
    api = {
      instance_type        = "t3.medium"
      root_volume_type     = "gp3"
      root_volume_size_gib = 30
      root_volume_iops     = 3000
      key_name             = "api-test"
    }
    worker = {
      instance_type        = "c6i.large"
      root_volume_type     = "gp2"
      root_volume_size_gib = 40
      key_name             = "worker-test"
    }
    database = {
      instance_type        = "m6i.large"
      root_volume_type     = "io2"
      root_volume_size_gib = 100
      root_volume_iops     = 5000
      key_name             = "database-test"
    }
    management = {
      instance_type        = "t3.micro"
      root_volume_type     = "gp3"
      root_volume_size_gib = 16
      root_volume_iops     = 3000
      key_name             = "management-test"
    }
  }
}

run "plan_five_instance_fleet" {
  command = plan

  assert {
    condition     = length(aws_instance.standard) == 4
    error_message = "Four standard instances should be planned."
  }

  assert {
    condition     = length(aws_instance.protected) == 1
    error_message = "Exactly one protected instance should be planned."
  }

  assert {
    condition     = contains(keys(aws_instance.protected), "management")
    error_message = "The management instance must be in the protected resource set."
  }

  assert {
    condition     = aws_instance.protected["management"].metadata_options[0].http_tokens == "required"
    error_message = "The protected instance must require IMDSv2."
  }

  assert {
    condition     = aws_instance.standard["database"].root_block_device[0].volume_type == "io2"
    error_message = "The database instance must exercise provisioned-IOPS storage."
  }
}

