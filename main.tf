locals {
  eks_name = "test"
  tags     = { "kubernetes.io/cluster/${local.eks_name}" = "shared" }
}

provider "aws" {
  region  = var.region
  version = "~> 2.49"
}

provider "random" { version = "~> 2.1" }

provider "kubernetes" {
  version = "~> 1.11"
  # To import k8s resources: aws eks update-kubeconfig --name test
  # Then comment below lines: 
  host                   = module.eks-master.cluster.endpoint
  cluster_ca_certificate = base64decode(module.eks-master.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks-master.cluster.name
}

module "simple-vpc" {
  # source              = "github.com/sgdan/tf-modules//simple-vpc?ref=0.4.0"
  source              = "../tf-modules/simple-vpc"
  custom_vpc_tags     = local.tags
  custom_private_tags = local.tags
}

# Test instance, can use SSM Session Manager to log in
# module "ssm-instance" {
#   source = "github.com/sgdan/tf-modules//ssm-instance?ref=0.4.0"
#   vpc_id = module.simple-vpc.vpc_id
# }

module "eks-master" {
  source = "../tf-modules/eks-master"
  name   = local.eks_name
  vpc_id = module.simple-vpc.vpc_id
}
module "eks-workers" {
  source          = "../tf-modules/eks-workers"
  name            = local.eks_name
  vpc_id          = module.simple-vpc.vpc_id
  worker_sg_id    = module.eks-master.worker_sg_id
  instance_types  = ["t3.medium", "t3a.medium"]
  cidrs           = [var.internet_whitelist]
  certificate_arn = var.certificate_arn
  domain          = var.domain
  prefix          = "rancher"
}
module "eks-config" {
  source          = "../tf-modules/eks-config"
  name            = local.eks_name
  worker_role_arn = module.eks-workers.worker_role_arn
}

# module "ecs" {
#   source             = "github.com/sgdan/tf-modules//ecs?ref=0.4.0"
#   vpc_id             = module.simple-vpc.vpc_id
#   private_subnet_ids = module.simple-vpc.private_subnet_ids
#   public_subnet_ids  = module.simple-vpc.public_subnet_ids
#   internet_whitelist = var.internet_whitelist
#   domain             = var.domain
#   certificate_arn    = var.certificate_arn
# }

# module "ecs-mysql" {
#   source = "github.com/sgdan/tf-modules//ecs-mysql?ref=0.4.0"
# }

# module "ecs-nexus" {
#   source = "github.com/sgdan/tf-modules//ecs-nexus?ref=0.4.0"
#   vpc_id = module.simple-vpc.vpc_id
#   domain = var.domain
# }

# Ubuntu linux desktop accessible from windows using RDP over SSH tunnel
# module "desktop" {
#   source     = "github.com/sgdan/tf-modules//desktop?ref=0.4.0"
#   vpc_id     = module.simple-vpc.vpc_id
#   subnet_id  = module.simple-vpc.public_subnet_ids[0]
#   public_key = var.desktop_public_key
#   domain     = var.domain
# }

# module "fargate" {
#   source = "../tf-modules/fargate"
#   vpc_id = module.simple-vpc.vpc_id
# }
# output "fargate" {
#   # Generate CLI command to run the task
#   value = <<EOT
#   aws ecs run-task \
#     --task-definition test-task \
#     --cluster test-cluster \
#     --launch-type FARGATE \
#     --network-configuration "awsvpcConfiguration={subnets=[${module.simple-vpc.private_subnet_ids[0]}],securityGroups=[${module.fargate.security_group}]}"
#   EOT
# }

