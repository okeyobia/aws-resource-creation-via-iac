variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)."
  type        = string
}

variable "project_name" {
  description = "Project name used for naming and tagging."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
}

variable "app_bucket_name" {
  description = "Globally unique name for the application S3 bucket."
  type        = string
}

variable "bucket_force_destroy" {
  description = "Allow destroying the app bucket when non-empty."
  type        = bool
  default     = false
}
