terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  # Backend blocks cannot use variables. Supply bucket/key/region at init time:
  #   terraform init -backend-config="bucket=<state-bucket>" \
  #                  -backend-config="key=<env>/terraform.tfstate" \
  #                  -backend-config="region=<region>"
  # Credentials come from the standard AWS credential chain (env, profile, SSO, OIDC).
  backend "s3" {
    encrypt      = true
    use_lockfile = true # native S3 locking via conditional writes; no DynamoDB table
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project_name
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "s3_storage" {
  source = "./modules/s3"

  environment   = var.environment
  bucket_name   = var.app_bucket_name
  force_destroy = var.bucket_force_destroy
}

module "iam_app_role" {
  source = "./modules/iam"

  environment = var.environment
  role_name   = "${var.project_name}-${var.environment}-app-role"
  bucket_arn  = module.s3_storage.bucket_arn
}
