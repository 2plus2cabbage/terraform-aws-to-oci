variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "environment_name" {
  description = "Environment name"
  type        = string
  default     = "cabbage"
}

variable "location" {
  description = "Location"
  type        = string
  default     = "location"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "cabbage-key"
}

variable "shared_secret_oci" {
  description = "Shared secret for OCI-AWS IPSEC tunnel"
  type        = string
  sensitive   = true
}

variable "my_public_ip" { 
  description = "Your public IP for RDP access"
  type        = string 
}

variable "oci_vpn_ip_tunnel1_temp" {
  description = "Dummy OCI VPN IP for temporary customer gateway"
  type        = string
}

variable "oci_vpn_ip_tunnel1" {
  description = "OCI VPN IP to be updated after OCI apply"
  type        = string
}