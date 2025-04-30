# Defines OCI networking values for IPSEC connection
locals {
  oci_vpn_ip_tunnel1_temp = var.oci_vpn_ip_tunnel1_temp  # Dummy OCI VPN IP
  oci_vpn_ip_tunnel1      = var.oci_vpn_ip_tunnel1       # To be updated after OCI apply
  oci_subnet_cidr         = "10.1.1.0/24"                # The private network on the OCI side
}