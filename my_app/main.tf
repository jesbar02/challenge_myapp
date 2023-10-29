terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  provider "aws" {
    region = "us-east-1"
  }

}

module "vpc" {
  source                          = "../modules//aws_vpc/"
  project                         = var.project
  cidr_block                      = "40.10.0.0/16"
  public_subnets                  = ["40.10.1.0/24", "40.10.2.0/24"]
  private_subnets                 = ["40.10.3.0/24", "40.10.4.0/24"]
  nat_gateway_public_subnet_index = 1
}

module "sg" {
  source  = "../modules//aws_sg/"
  project = var.project
  vpc_id  = module.vpc.vpc_id
}

module "asg" {
  source             = "../modules//aws_asg/"
  project            = var.project
  asg_min_size       = 1
  asg_max_size       = 2
  asg_size           = 2
  vpc_ec2_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.sg.sg_ec2_id]
}

module "alb" {
  source              = "../modules//aws_alb/"
  project             = var.project
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  alb_security_groups = [module.sg.sg_alb_id]
}
