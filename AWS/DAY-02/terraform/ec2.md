# AWS Day-02 Terraform Setup

This folder provisions a basic AWS environment using Terraform:

- `aws_key_pair.my_key_pair`: creates an AWS key pair from local public key file `C:\Users\harik\.ssh\id_ed25519.pub`
- `aws_default_vpc.my_default_vpc`: references the default VPC in the account
- `aws_security_group.my_aws_security_gp`: creates a security group in the default VPC with rules:
  - ingress SSH (TCP 22) from anywhere
  - ingress HTTP (TCP 80) from anywhere
  - egress all traffic (0.0.0.0/0)
- `aws_instance.my_aws_tf_instance`: creates an EC2 instance using:
  - AMI `ami-0b6c6ebed2801a5cb`
  - instance type `t3.micro`
  - key pair `my_dev_key`
  - the above security group
  - root volume 10 GiB gp3

## Setup

1. Confirm AWS credentials are configured (environment variables, shared credentials, or AWS SSO).
2. Adjust region in `provider.tf`, e.g., `us-east-1`.
3. Ensure local key file exists: `C:\Users\harik\.ssh\id_ed25519.pub`.
4. Optionally set `ami`, `instance_type`, and CIDR blocks as needed.

## Commands

```bash
cd folder
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

## Notes

- `aws_default_vpc` uses the existing managed default VPC and does not create a new VPC.
- The current security group allows SSH/HTTP from anywhere; lock this down for production.
- Replace the hardcoded AMI ID with a data source for cross-region stability.
