# Creates a security group to control traffic to the subnet
resource "aws_security_group" "cabbage_sg" {
  vpc_id                   = aws_vpc.cabbage_vpc.id                             # VPC ID for the security group
  name                     = "${local.security_group_name_prefix}sg"            # Name of the security group
  description              = "Allow RDP and outbound traffic"                   # Description of the security group
  ingress {
    from_port              = 3389                                               # RDP port
    to_port                = 3389                                               # RDP port
    protocol               = "tcp"                                              # Protocol for RDP
    cidr_blocks            = [var.my_public_ip]                                 # Source IP for RDP access
    description            = "RDP from your IP"                                 # Description of the rule
  }
  ingress {
    from_port              = -1                                                 # All ICMP types
    to_port                = -1                                                 # All ICMP codes
    protocol               = "icmp"                                             # Protocol for ICMP
    cidr_blocks            = [local.oci_subnet_cidr]                            # Source subnet (OCI) for ICMP traffic
    description            = "ICMP from OCI subnet"                             # Description of the rule
  }
  egress {
    from_port              = 0                                                  # All ports for outbound traffic
    to_port                = 0                                                  # All ports for outbound traffic
    protocol               = "-1"                                               # All protocols for outbound traffic
    cidr_blocks            = ["0.0.0.0/0"]                                      # Allow all outbound destinations
    description            = "Allow all outbound traffic"                       # Description of the rule
  }
  tags = {
    Name                   = "${local.security_group_name_prefix}sg"            # Name of the security group
  }
}