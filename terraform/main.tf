provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source              = "./modules/vpc"
  aws_region          = var.aws_region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs= var.private_subnet_cidrs
  cluster_name        = var.cluster_name
  name                = var.cluster_name
}

module "eks" {
  source             = "./modules/eks"
  aws_region         = var.aws_region
  cluster_name       = var.cluster_name
  private_subnet_ids  = module.vpc.private_subnet_ids
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  instance_types     = var.instance_types
  ami_type           = var.ami_type
  tags               = var.tags
}


module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.repository_name
}
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}



