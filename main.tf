provider "aws" {
  region  = var.region
  version = "~> 2.14"
}

provider "local" { version = "~> 1.2" }
provider "random" { version = "~> 2.1" }

data "aws_availability_zones" "all" {}

# Simple VPC with public and private subnets in two availability zones
# Each subnet has 8192 addresses
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.7.0"

  name            = "simple-vpc"
  cidr            = "192.168.0.0/16"
  azs             = [data.aws_availability_zones.all.names[0], data.aws_availability_zones.all.names[1]]
  public_subnets  = ["192.168.0.0/19", "192.168.32.0/19"]
  private_subnets = ["192.168.64.0/19", "192.168.96.0/19"]
  public_subnet_tags = {
    Tier = "public"
  }
  private_subnet_tags = {
    Tier = "private"
  }

  # will use NAT instance instead since it's cheaper
  enable_nat_gateway = false
}

# Empty default sg with no ingress/egress allowed
resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id
}

module "nat-instance" {
  source = "../tf-modules/nat-instance"
  vpc_id = module.vpc.vpc_id
}

# Test instance, can use SSM Session Manager to log in
module "ssm-instance" {
  source = "../tf-modules/ssm-instance"
  vpc_id = module.vpc.vpc_id
}

module "eks-master" {
  source = "../tf-modules/eks-master"
  vpc_id = module.vpc.vpc_id
}

module "eks-workers" {
  source       = "../tf-modules/eks-workers"
  vpc_id       = module.vpc.vpc_id
  worker_sg_id = module.eks-master.worker_sg_id
}

module "eks-config" {
  source          = "../tf-modules/eks-config"
  worker_role_arn = module.eks-workers.worker_role_arn
}
