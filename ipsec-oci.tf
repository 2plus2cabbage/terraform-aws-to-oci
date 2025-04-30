# Creates a temporary customer gateway with a dummy OCI VPN IP
resource "aws_customer_gateway" "oci_customer_gateway_temp" {
  bgp_asn                  = 65000                                              # BGP ASN for OCI
  ip_address               = local.oci_vpn_ip_tunnel1_temp                      # Dummy OCI VPN IP
  type                     = "ipsec.1"                                          # IPSEC type
  tags = {
    Name                   = "${local.cpe_name_prefix}oci-temp"                 # Name of the temporary customer gateway
  }
}

# Creates the final customer gateway to be updated with the real OCI VPN IP
resource "aws_customer_gateway" "oci_customer_gateway" {
  bgp_asn                  = 65000                                              # BGP ASN for OCI
  ip_address               = local.oci_vpn_ip_tunnel1                           # To be updated after OCI apply
  type                     = "ipsec.1"                                          # IPSEC type
  tags = {
    Name                   = "${local.cpe_name_prefix}oci"                      # Name of the customer gateway
  }
}

# Creates the VPN connection between AWS and OCI
resource "aws_vpn_connection" "aws_to_oci_vpn" {
  vpn_gateway_id           = aws_vpn_gateway.cabbage_vpn_gateway.id             # VPN Gateway ID
  customer_gateway_id      = aws_customer_gateway.oci_customer_gateway_temp.id  # TEMP Customer Gateway ID
  #customer_gateway_id      = aws_customer_gateway.oci_customer_gateway.id       # FINAL Customer Gateway ID
  type                     = "ipsec.1"                                          # IPSEC type
  static_routes_only       = true                                               # Use static routes
  tunnel1_preshared_key    = var.shared_secret_oci                              # Shared secret for IPSEC tunnel
  tags = {
    Name                   = "${local.vpn_tunnel_name_prefix}to-oci"            # Name of the VPN connection
  }
}

# Defines the route to the OCI subnet through the VPN connection
resource "aws_vpn_connection_route" "route_to_oci" {
  destination_cidr_block   = local.oci_subnet_cidr                              # OCI subnet CIDR
  vpn_connection_id        = aws_vpn_connection.aws_to_oci_vpn.id               # VPN connection ID
}

# Outputs the AWS VPN Gateway public IP
output "aws_vpn_ip_oci_tunnel1" {
  value                    = aws_vpn_connection.aws_to_oci_vpn.tunnel1_address  # Public IP of AWS VPN Gateway
  description              = "Public IP of AWS VPN to OCI"                      # Description of the output
}