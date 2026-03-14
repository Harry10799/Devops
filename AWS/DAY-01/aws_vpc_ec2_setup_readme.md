# AWS EC2 Setup in VPC

This project demonstrates how to configure an AWS network architecture
using **VPC, Public Subnet, Private Subnet, Internet Gateway, NAT
Gateway, and EC2 instances**.

The setup allows: - Public access to EC2 instances in the public
subnet - Secure private instances in the private subnet - Outbound
internet access from private subnet through NAT Gateway

------------------------------------------------------------------------

## Architecture Overview

The infrastructure consists of:

-   VPC: 12.0.0.0/16
-   Public Subnet: 12.0.1.0/24
-   Private Subnet: 12.0.2.0/24
-   Internet Gateway
-   NAT Gateway
-   Route Tables
-   EC2 Instances

Architecture Flow:

Internet → Internet Gateway → Public Subnet → NAT Gateway → Private
Subnet

------------------------------------------------------------------------

# Components

## 1. VPC Creation

Create a VPC with the following configuration:

  Parameter    Value
  ------------ -------------
  Name         my-project-vpc
  CIDR Block   12.0.0.0/16
  Tenancy      Default

Purpose: Provides isolated network for AWS resources.

------------------------------------------------------------------------

## 2. Subnets

### Public Subnet

  Parameter               Value
  ----------------------- ---------------
  Name                    my-project-public-subnet
  CIDR                    12.0.1.0/24
  Auto Assign Public IP   Enabled

Used for: - Bastion host - Public facing EC2 - NAT Gateway

### Private Subnet

  Parameter               Value
  ----------------------- ----------------
  Name                    my-project-private-subnet
  CIDR                    12.0.2.0/24
  Auto Assign Public IP   Disabled

Used for: - Backend servers - Databases - Internal services

------------------------------------------------------------------------

# Internet Gateway

Steps:

1.  Go to AWS VPC Console
2.  Create Internet Gateway
3.  Attach it to the VPC

Purpose: Allows internet access to public subnet resources.

------------------------------------------------------------------------

# NAT Gateway

Steps:

1.  Allocate Elastic IP
2.  Create NAT Gateway
3.  Select Public Subnet
4.  Attach Elastic IP

Purpose: Allows private subnet instances to access the internet
securely.

------------------------------------------------------------------------

# Route Tables

## Public Route Table

  Destination   Target
  ------------- ------------------
  0.0.0.0/0     Internet Gateway

Associate this route table with Public Subnet.

## Private Route Table

  Destination   Target
  ------------- -------------
  0.0.0.0/0     NAT Gateway

Associate this route table with Private Subnet.

------------------------------------------------------------------------

# EC2 Instances

## Public EC2 Instance

Configuration:

  Parameter        Value
  ---------------- ---------------
  Subnet           Public Subnet
  Public IP        Enabled
  Security Group   SSH allowed

Access:

ssh -i key.pem ec2-user@public-ip

Purpose: Acts as a Bastion / Jump server.

------------------------------------------------------------------------

## Private EC2 Instance

Configuration:

  Parameter        Value
  ---------------- ---------------------------
  Subnet           Private Subnet
  Public IP        Disabled
  Security Group   Allow SSH from Public EC2

Access from public instance:

ssh ec2-user@private-ip

------------------------------------------------------------------------

# Security Groups

## Public Instance SG

  Type   Port   Source
  ------ ------ ---------
  SSH    22     Your IP

## Private Instance SG

  Type   Port   Source
  ------ ------ ---------------------------
  SSH    22     Public EC2 Security Group

------------------------------------------------------------------------

# Connectivity Test

1.  SSH into Public EC2

ssh -i key.pem ec2-user@public-ip

2.  From Public EC2 connect to Private EC2

ssh ec2-user@private-ip

3.  Test internet from Private EC2

ping google.com

If NAT Gateway is configured correctly, the request should succeed.

------------------------------------------------------------------------

# Best Practices

-   Do not expose private instances to the internet
-   Use Bastion host for secure access
-   Restrict Security Groups to required sources only
-   Use IAM Roles instead of storing credentials

------------------------------------------------------------------------

# Learning Outcome

After completing this project you will understand:

-   AWS VPC fundamentals
-   Public vs Private subnet architecture
-   NAT Gateway usage
-   Secure EC2 access patterns
