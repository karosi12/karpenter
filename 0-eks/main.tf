provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

terraform {
  backend "s3" {
    bucket  = "terraform-state-opsfleet-1"
    key     = "eks-0/terraform.tfstate"
    region  = "eu-central-1" # Change this to your desired region
    encrypt = true
    use_lockfile =  true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

module "vpc" {
  source                            = "./modules/vpc"
  vpc_name                          = var.vpc_name
  cidr_block                        = var.cidr_block
  private_subnet_cidr_eu_central_1a = var.private_subnet_cidr_eu_central_1a
  private_subnet_cidr_eu_central_1b = var.private_subnet_cidr_eu_central_1b
  public_subnet_cidr_eu_central_1a  = var.public_subnet_cidr_eu_central_1a
  public_subnet_cidr_eu_central_1b  = var.public_subnet_cidr_eu_central_1b
  availability_zone1                = var.availability_zone1
  availability_zone2                = var.availability_zone2
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_id
  subnet_ids         = module.vpc.subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  account_id         = var.account_id
  region             = var.region
  capacity_type      = var.capacity_type
}

