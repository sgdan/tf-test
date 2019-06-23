provider "aws" {
  region  = var.region
  version = "~> 2.16"
}

module "simple-vpc" {
  #source = "../tf-modules/simple-vpc"
  source = "github.com/sgdan/tf-modules//simple-vpc?ref=0.1.0"
}

# Test instance, can use SSM Session Manager to log in
module "ssm-instance" {
  #source = "../tf-modules/ssm-instance"
  source = "github.com/sgdan/tf-modules//ssm-instance?ref=0.1.0"
  vpc_id = module.simple-vpc.vpc_id
}

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
