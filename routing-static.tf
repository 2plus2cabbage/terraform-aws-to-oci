# Creates a route table to direct traffic from the subnet to the internet and OCI
resource "aws_route_table" "cabbage_route_table" {
  vpc_id                   = aws_vpc.cabbage_vpc.id                             # VPC ID for the route table
  route {
    cidr_block             = "0.0.0.0/0"                                        # Route all traffic
    gateway_id             = aws_internet_gateway.cabbage_igw.id                # Direct to internet gateway
  }
  route {
    cidr_block             = local.oci_subnet_cidr                              # Route to OCI subnet
    gateway_id             = aws_vpn_gateway.cabbage_vpn_gateway.id             # Direct to VPN Gateway
  }
  tags = {
    Name                   = "${local.route_table_name_prefix}001"              # Name of the route table
  }
}

# Associates the route table with the subnet for internet access
resource "aws_route_table_association" "cabbage_route_assoc" {
  subnet_id                = aws_subnet.cabbage_subnet.id                       # Subnet ID to associate
  route_table_id           = aws_route_table.cabbage_route_table.id             # Route table ID
}