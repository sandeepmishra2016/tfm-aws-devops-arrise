provider "aws" {
  alias   = "account_a"
  region  = var.aws_region
  profile = var.account_a_profile

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "arrise-devops-assignment"
      Account   = "A"
    }
  }
}

provider "aws" {
  alias   = "account_b"
  region  = var.aws_region
  profile = var.account_b_profile

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "arrise-devops-assignment"
      Account   = "B"
    }
  }
}

