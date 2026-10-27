# AWS Infrastructure with Terraform

Modular, production-oriented Terraform that provisions a VPC, a secured S3 bucket, and an EC2 IAM role scoped to that bucket. State is stored remotely in S3 using **native S3 state locking** (`use_lockfile = true`), so no DynamoDB table is required.

## Requirements

- Terraform `>= 1.10.0`
- AWS provider `~> 5.70`
- AWS credentials from the standard credential chain (environment variables, shared profile, SSO, or OIDC). No credentials are stored in this repo.

## Layout

```
.
├── bootstrap/        # One-time stack: creates the S3 state bucket (local state)
├── modules/
│   ├── vpc/          # VPC, public/private subnets, IGW, public route table
│   ├── s3/           # Versioned, AES256-encrypted, fully private bucket
│   └── iam/          # EC2 role + least-privilege policy on the S3 bucket
├── main.tf           # Root module, providers, backend "s3" block
├── variables.tf
├── outputs.tf
└── terraform.tfvars  # Default values
```

## Modules

| Module | Resources |
|--------|-----------|
| `vpc` | VPC (DNS hostnames and support enabled), public and private subnets, Internet Gateway, public route table and associations |
| `s3` | Bucket, versioning, AES256 default encryption, public access block (all four settings) |
| `iam` | EC2-trusted role, policy limited to the bucket ARN (`ListBucket` on the bucket; Get/Put/Delete object on `bucket/*`), instance profile |

Wiring: `module.s3_storage.bucket_arn` is passed into `module.iam_app_role`.
All resources are tagged with `Environment`.

## Usage

### 1. Bootstrap the remote backend (once)

```bash
cd bootstrap
terraform init
terraform apply
terraform output -raw backend_init_command
cd ..
```

The bootstrap stack uses local state, because the bucket does not exist yet. Keep (and back up) its `terraform.tfstate`. The bucket has `prevent_destroy` set.

### 2. Deploy the main infrastructure

Edit `terraform.tfvars` (in particular `app_bucket_name`, which must be globally unique), then run the command printed above, for example:

```bash
terraform init \
  -backend-config="bucket=<state-bucket>" \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="region=us-east-1"

terraform plan
terraform apply
```

Backend blocks cannot reference variables, so bucket, key, and region are supplied at init time. The backend block itself sets `encrypt = true` and `use_lockfile = true`; locking creates a `<key>.tflock` object in the state bucket.

## Variables (root)

| Name | Description | Default |
|------|-------------|---------|
| `aws_region` | Deployment region | `us-east-1` |
| `environment` | Environment name / tag | required |
| `project_name` | Naming and tagging | required |
| `vpc_cidr` | VPC CIDR | required |
| `availability_zones` | AZs for subnets | required |
| `public_subnet_cidrs` | Public subnet CIDRs | required |
| `private_subnet_cidrs` | Private subnet CIDRs | required |
| `app_bucket_name` | Globally unique app bucket name | required |
| `bucket_force_destroy` | Allow destroying non-empty bucket | `false` |

## Outputs

`vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `bucket_arn`, `app_role_arn`, `app_instance_profile_name`.

## Notes

- The caller needs S3 permissions on the state bucket: `s3:ListBucket`, `s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` (the last is required to release the lock file).
- Private subnets have no NAT gateway or routes by default; add one if workloads need outbound internet access.
- Commit `.terraform.lock.hcl`; never commit state files (see `.gitignore`).
