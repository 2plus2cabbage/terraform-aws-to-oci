# Creates a virtual private cloud (VPC) to host the subnet and resources
resource "aws_vpc" "cabbage_vpc" {
  cidr_block           = "10.3.0.0/16"                                      # CIDR block for the VPC
  enable_dns_support   = true                                               # Enable DNS support
  enable_dns_hostnames = true                                               # Enable DNS hostnames
  tags = {
    Name               = "${local.vpc_name}1030016"                         # Name of the VPC
  }
}

# Creates a subnet within the VPC for the Windows VM
resource "aws_subnet" "cabbage_subnet" {
  vpc_id               = aws_vpc.cabbage_vpc.id                             # VPC ID for the subnet
  cidr_block           = "10.3.1.0/24"                                      # CIDR block for the subnet
  availability_zone    = "${var.region}a"                                   # Availability zone for the subnet (e.g., us-east-1a)
  tags = {
    Name               = "${local.subnet_name_prefix}1031024"               # Name of the subnet
  }
}

# Creates an internet gateway to allow internet access for the VPC
resource "aws_internet_gateway" "cabbage_igw" {
  vpc_id               = aws_vpc.cabbage_vpc.id                             # VPC ID for the internet gateway
  tags = {
    Name               = "${local.internet_gateway_name_prefix}001"         # Name of the internet gateway
  }
}