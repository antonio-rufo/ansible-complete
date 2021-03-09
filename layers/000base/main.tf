# 000base layer
###############################################################################
# Terraform main config
###############################################################################

### PLEASE UPDATE BACKEND BUCKET NAME AND REGION

terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = "~> 3.6.0"
  }
  backend "s3" {
    bucket = "130541009828-build-state-bucket-ansible-complete"
    # This key must be unique for each layer!
    key     = "terraform.development.000base.tfstate"
    region  = "ap-southeast-2"
    encrypt = "true"
  }
}

###############################################################################
# Providers
###############################################################################
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

locals {
  tags = {
    Environment = var.environment
  }
}

data "aws_availability_zones" "available" {
}

###############################################################################
# Base Network
###############################################################################
module "base_network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  name                 = var.vpc_name
  cidr                 = var.cidr_range
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.public_cidr_ranges
  public_subnets       = var.private_cidr_ranges
  enable_nat_gateway   = true
  enable_dns_hostnames = true
  tags                 = local.tags
}
