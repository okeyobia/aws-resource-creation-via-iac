aws_region   = "us-east-1"
environment  = "dev"
project_name = "myapp"

vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# Must be globally unique; change before applying.
app_bucket_name      = "aws-resource-iac-dev-156"
bucket_force_destroy = false
