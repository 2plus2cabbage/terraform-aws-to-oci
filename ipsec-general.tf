# Creates a virtual private gateway (VPN Gateway) for IPSEC connections
resource "aws_vpn_gateway" "cabbage_vpn_gateway" {
  vpc_id                   = aws_vpc.cabbage_vpc.id                             # VPC ID for the VPN Gateway
  tags = {
    Name                   = "${local.vpn_gateway_name_prefix}aws-001"          # Name of the VPN Gateway
  }
}

# Attaches the VPN Gateway to the VPC
resource "aws_vpn_gateway_attachment" "cabbage_vpn_attachment" {
  vpc_id                   = aws_vpc.cabbage_vpc.id                             # VPC ID for the attachment
  vpn_gateway_id           = aws_vpn_gateway.cabbage_vpn_gateway.id             # VPN Gateway ID to attach
}