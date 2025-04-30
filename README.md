<img align="right" width="150" src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/2plus2cabbage.png">

<img src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/aws-to-oci.png" alt="aws-to-oci" width="300" align="left">
<br clear="left">

# AWS-to-OCI Cross-Cloud Terraform Deployment

Deploys a Windows Server 2022 VM in Amazon Web Services (AWS) with RDP, internet access, and an IPSEC VPN tunnel to a corresponding Windows VM in OCI for cross-cloud communication.

## Files
The project is split into multiple files to illustrate modularity and keep separate constructs distinct, making it easier to manage and understand.
- `main.tf`: Terraform provider block (`hashicorp/aws`).
- `awsprovider.tf`: AWS provider config with `access_key`, `secret_key`, etc.
- `variables.tf`: Variables for region, etc.
- `terraform.tfvars.template`: Template for sensitive/custom values; rename to `terraform.tfvars` and add your credentials.
- `locals.tf`: Local variables for naming conventions.
- `aws-networking.tf`: VPC, subnet, internet gateway.
- `oci-networking.tf`: OCI networking values (`oci_vpn_ip_tunnel1_temp`, `oci_vpn_ip_tunnel1`, `oci_subnet_cidr`) for IPSEC.
- `securitygroup.tf`: Security group for RDP (TCP 3389), ICMP, and outbound traffic.
- `routing-static.tf`: Route table for internet access and OCI subnet routing.
- `ipsec-general.tf`: Shared IPSEC infrastructure (virtual private gateway).
- `ipsec-oci.tf`: OCI-specific IPSEC resources (customer gateway, VPN connection).
- `windows.tf`: Windows VM, outputs public/private IPs.

## How It Works
- **Networking**: VPC and subnet provide connectivity. Route table enables inbound/outbound traffic and routes to OCI subnet via the IPSEC tunnel.
- **Security**: Allows RDP from your IP, ICMP from the OCI subnet, and all outbound traffic.
- **Instance**: Windows Server 2022 VM with public IP, firewall disabled via user data.
- **IPSEC Tunnel**: Establishes a VPN connection to an OCI project, allowing communication between the AWS and OCI Windows VMs.

## Prerequisites
- An AWS account with a key pair for EC2 instances.
- AWS credentials, noting `access_key`, `secret_key`, and `region`.
- A corresponding OCI project with IPSEC support, providing the `oci_vpn_ip_tunnel1` output.
- Terraform installed on your machine.
- Examples are demonstrated using Visual Studio Code (VSCode).
- **Note**: Cloud providers regularly change their console interfaces without notice. Steps outlined today may not apply exactly tomorrow.

## Procedural Note
The AWS project must be deployed first to obtain the VPN IP that will be added to the OCI project configuration.

## Deployment Steps
1. Update `terraform.tfvars` with AWS credentials, key pair name in `key_name`, your public IP in `my_public_ip`, and the OCI VPN IPs in `oci_vpn_ip_tunnel1_temp` and `oci_vpn_ip_tunnel1`.
2. Run `terraform init`, then (optionally) `terraform plan` to preview changes, then `terraform apply` (type `yes`).
3. Get the public IP from the `aws_vm_public_ip` output on the screen, or run `terraform output aws_vm_public_ip`, or check in the AWS Console under **EC2 > Instances**. Note the `aws_vpn_ip_tunnel1` output for use in the OCI project.
4. Retrieve the initial password in the AWS Console under **EC2 > Instances > [select instance] > Actions > Security > Get Windows Password**, using the key pair specified in `key_name`.
5. In the OCI project, update `terraform.tfvars` with the `aws_vpn_ip_tunnel1` in `aws_vpn_ip`, deploy the OCI project with `terraform apply`, note the `oci_vpn_ip_tunnel1` output, and retrieve the shared secret from the OCI Console under **Networking > Customer Connectivity > Site-to-Site VPN > ipsec-<environment_name>-<location>-to-aws-001 > View (next to Configuration details)**, then click **... > View shared secret** (e.g., `abc123...`). Be sure to select the tunnel with the correct VPN IP address that was displayed in the Terraform output.
6. In this AWS project, update `terraform.tfvars` with the `oci_vpn_ip_tunnel1` output in `oci_vpn_ip_tunnel1`, update `shared_secret_oci` with the shared secret from OCI, and run `terraform apply`.
7. Switch the Customer Gateway to `cgw-<environment_name>-<location>-oci` in the AWS Console under **VPC > Virtual private network (VPN) > Site-to-Site VPN connections > vpn-<environment_name>-<location>-to-oci > Actions > Modify VPN connection**, and wait for the VPN connection state to change from `modifying` to `available`. The tunnel should come up after a few minutes (up to 15 minutes could be expected).
8. Run `terraform state rm aws_vpn_connection.aws_to_oci_vpn` to remove the VPN connection from the state (first step to sync Terraform state with deployed state).
9. Run `terraform import aws_vpn_connection.aws_to_oci_vpn <vpn-id>` (get the VPN ID from the AWS Console under **VPC > Virtual private network (VPN) > Site-to-Site VPN connections > vpn-<environment_name>-<location>-to-oci**) to import the updated VPN connection state (second step to sync Terraform state with deployed state).
10. Update `ipsec-oci.tf` to set `customer_gateway_id` to `aws_customer_gateway.oci_customer_gateway.id`, and run `terraform apply` to complete the tunnel setup (final step to sync Terraform state with deployed state; no changes are actually made so this should be very quick).
11. Verify the tunnel in the AWS Console under **VPC > Site-to-Site VPN Connections** (should show "Up" for tunnel status).
12. Use Remote Desktop to log in with the `Administrator` user and the retrieved initial password, using the public IP from the `aws_vm_public_ip` output.
13. From the AWS VM, ping the OCI VM’s private IP (`oci_vm_private_ip` output) to confirm connectivity; then from the OCI VM, ping the AWS VM’s private IP (`aws_vm_private_ip` output) to confirm bidirectional connectivity.
14. To remove all resources, run `terraform destroy` (type `yes`).

## Potential costs and licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to fully understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.