provider "aws" {
  region  = var.region
  version = "~> 2.16"
}
provider "random" { version = "~> 2.1" }

module "simple-vpc" {
  source = "github.com/sgdan/tf-modules//simple-vpc?ref=0.3.0"
}

# Test instance, can use SSM Session Manager to log in
# module "ssm-instance" {
#   source = "github.com/sgdan/tf-modules//ssm-instance?ref=0.3.0"
#   vpc_id = module.simple-vpc.vpc_id
# }

# module "eks-master" {
#   source = "../tf-modules/eks-master"
#   vpc_id = module.simple-vpc.vpc_id
# }
# module "eks-workers" {
#   source       = "../tf-modules/eks-workers"
#   vpc_id = module.simple-vpc.vpc_id
#   worker_sg_id = module.eks-master.worker_sg_id
# }
# module "eks-config" {
#   source          = "../tf-modules/eks-config"
#   worker_role_arn = module.eks-workers.worker_role_arn
# }

module "ecs" {
  source             = "github.com/sgdan/tf-modules//ecs?ref=0.3.0"
  vpc_id             = module.simple-vpc.vpc_id
  private_subnet_ids = module.simple-vpc.private_subnet_ids
  public_subnet_ids  = module.simple-vpc.public_subnet_ids
  internet_whitelist = var.internet_whitelist
  domain             = var.domain
  certificate_arn    = var.certificate_arn
}

# module "ecs-mysql" {
#   source = "github.com/sgdan/tf-modules//ecs-mysql?ref=0.2.0"
# }

module "ecs-nexus" {
  source = "github.com/sgdan/tf-modules//ecs-nexus?ref=0.3.0"
  vpc_id = module.simple-vpc.vpc_id
  domain = var.domain
}
