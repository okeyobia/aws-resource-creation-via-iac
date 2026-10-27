variable "aws_region" {
  description = "AWS region for the state bucket."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (used for the Environment tag and bucket naming)."
  type        = string
}

variable "project_name" {
  description = "Project name used for bucket naming."
  type        = string
}

variable "state_bucket_name" {
  description = "Explicit state bucket name. If null, a name is derived from project, environment, account ID and region."
  type        = string
  default     = null
}

variable "noncurrent_version_retention_days" {
  description = "Days to retain noncurrent state file versions."
  type        = number
  default     = 90
}
