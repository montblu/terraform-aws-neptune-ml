provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Purpose   = "${local.name} example"
      ManagedBy = "Terraform"
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  name   = "Amazon Neptune ML - simple"
  region = "eu-north-1"

  vpc_cidr = "172.31.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = local.name
  cidr = local.vpc_cidr

  azs              = local.azs
  private_subnets  = [for i, _ in local.azs : cidrsubnet(local.vpc_cidr, 4, i)]
  database_subnets = [for i, _ in local.azs : cidrsubnet(local.vpc_cidr, 4, i + length(local.azs))]
}

module "neptune_ml" {
  source = "../../"

  resource_group_name = "simple"
  vpc_id              = module.vpc.vpc_id
  route_table_ids     = module.vpc.private_route_table_ids
  neptune_subnet_ids  = module.vpc.database_subnets
  extra_subnet_ids    = module.vpc.private_subnets

  # If using this example then you are strongly recommended to provide a value
  # to at least one of these. Otherwise only the root account will be admin of
  # the KMS key and you will not be able to modify it later without root access
  kms_admin_role_names = []
  kms_admin_user_names = []
}
