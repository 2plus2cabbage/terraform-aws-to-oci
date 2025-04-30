# Defines local variables for naming conventions in AWS
locals {
  vpc_name                      = "vpc-${var.environment_name}-${var.location}-"           # Prefix for VPC name
  subnet_name_prefix            = "snet-${var.environment_name}-${var.location}-"          # Prefix for subnet name
  windows_name_prefix           = "vm-${var.environment_name}-${var.location}-windows-"    # Prefix for Windows VM name
  security_group_name_prefix    = "secgroup-${var.environment_name}-${var.location}-"      # Prefix for security group name
  internet_gateway_name_prefix  = "igw-${var.environment_name}-${var.location}-"           # Prefix for internet gateway name
  route_table_name_prefix       = "rt-${var.environment_name}-${var.location}-"            # Prefix for route table name
  eip_name_prefix               = "eip-${var.environment_name}-${var.location}-"           # Prefix for Elastic IP name
  cpe_name_prefix               = "cgw-${var.environment_name}-${var.location}-"           # Prefix for customer gateway (CPE) name
  vpn_gateway_name_prefix       = "vgw-${var.environment_name}-${var.location}-"           # Prefix for VPN gateway name
  vpn_connection_name_prefix    = "vpn-${var.environment_name}-${var.location}-"           # Prefix for VPN connection name
  vpn_tunnel_name_prefix        = "vpn-${var.environment_name}-${var.location}-"           # Prefix for VPN tunnel name
}