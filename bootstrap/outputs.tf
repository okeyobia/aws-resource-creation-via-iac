output "state_bucket_name" {
  description = "Name of the Terraform state bucket."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket."
  value       = aws_s3_bucket.state.arn
}

output "backend_init_command" {
  description = "Command to initialise the root module against this backend."
  value       = "terraform init -backend-config=\"bucket=${aws_s3_bucket.state.id}\" -backend-config=\"key=${var.environment}/terraform.tfstate\" -backend-config=\"region=${var.aws_region}\""
}
