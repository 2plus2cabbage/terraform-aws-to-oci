# Detailed Deployment Guide: AWS-to-OCI Cross-Cloud Terraform Deployment

This guide provides step-by-step instructions to deploy a Windows Server 2022 VM in Amazon Web Services (AWS) with RDP, internet access, and an IPSEC VPN tunnel to a corresponding Windows VM in OCI for cross-cloud communication.

## Prerequisites
Before starting, ensure you have the following:
- An AWS account with a key pair for EC2 instances (e.g., `cabbage-key`).
- AWS credentials: `access_key` and `secret_key` (found in AWS Console under **IAM > Users > [your user] > Security credentials**).
- A corresponding OCI project with IPSEC support, providing the `oci_vpn_ip_tunnel1` output.
- Terraform installed on your machine.
- Visual Studio Code (VSCode) or another editor for modifying files.
- Your public IP address for RDP access (e.g., `203.0.113.5/32`; find it using a service like `whatismyipaddress.com`).
- **Note**: Cloud providers regularly change their console interfaces without notice. Steps outlined today may not apply exactly tomorrow.

## Deployment Steps

### Step 1: Update `terraform.tfvars` with AWS Credentials and Configuration
1. Open the `terraform.tfvars` file in your editor (e.g., VSCode).
2. Update the following fields with your information:
   - `aws_access_key`: Replace `"<your-access-key>"` with your AWS Access Key ID (e.g., `AKIA...`).
   - `aws_secret_key`: Replace `"<your-secret-key>"` with your AWS Secret Access Key (e.g., `wJal...`).
   - `region`: Replace `"<your-region>"` with your AWS region (e.g., `us-east-1`).
   - `environment_name`: Replace `"<your-environment-name>"` with your environment name (e.g., `cabbage`).
   - `location`: Replace `"<your-location>"` with your location identifier (e.g., `useast1`).
   - `my_public_ip`: Replace `"<your-public-ip>"` with your public IP for RDP access (e.g., `203.0.113.5/32`).
   - `key_name`: Replace `"<your-key-name>"` with your EC2 key pair name (e.g., `cabbage-key`).
   - `oci_vpn_ip_tunnel1_temp`: Replace `"<oci-vpn-ip-tunnel1-temp>"` with the dummy OCI VPN IP (e.g., `1.1.1.1`).
   - Leave `oci_vpn_ip_tunnel1` as `"<oci-vpn-ip-tunnel1>"` (you’ll update this later after deploying OCI).
   - Leave `shared_secret_oci` as `"<your-shared-secret>"` (you’ll update this later).
3. Save the file.

### Step 2: Initialize and Deploy the AWS Project
1. Open a terminal in the AWS project directory.
2. Run `terraform init` to initialize the Terraform working directory and download providers. This should take about 30 seconds.
3. (Optional) Run `terraform plan` to preview the changes Terraform will make. Review the output to ensure it looks correct (should take 15-30 seconds).
4. Run `terraform apply` to deploy the AWS resources. Type `yes` when prompted to confirm. This will create the VPC, subnet, VM, and VPN resources (takes about 2-5 minutes).

### Step 3: Retrieve the AWS VM Public IP and VPN IP
1. After deployment, Terraform will output several values. Note the `aws_vpn_ip_tunnel1` value (e.g., `52.86.55.82`) for use in the OCI project.
2. To get the public IP of the AWS VM, run `terraform output aws_vm_public_ip` in the terminal. Note this IP (e.g., `54.123.45.67`) for RDP access.
3. Alternatively, find the public IP in the AWS Console:
   - Go to **EC2 > Instances**.
   - Locate the instance named `vm-<environment_name>-<location>-windows-001` (e.g., `vm-cabbage-useast1-windows-001`).
   - Note the "Public IPv4 address" in the details pane.

### Step 4: Retrieve the AWS VM Initial Password
1. Go to the AWS Console: **EC2 > Instances**.
2. Select the instance named `vm-<environment_name>-<location>-windows-001`.
3. Click **Actions > Security > Get Windows Password**.
4. Upload or paste the private key associated with your key pair (`key_name` from `terraform.tfvars`, e.g., `cabbage-key`).
5. Click **Decrypt Password** to retrieve the initial password for the `Administrator` user. Note this password for RDP access.

### Step 5: Deploy the OCI Project with the AWS VPN IP
1. In the OCI project directory, open the `terraform.tfvars` file in your editor.
2. Update the `aws_vpn_ip` field with the `aws_vpn_ip_tunnel1` value from step 3 (e.g., `52.86.55.82`).
3. Save the file.
4. In the OCI project terminal, run `terraform init` to initialize Terraform (if not already done).
5. (Optional) Run `terraform plan` to preview changes.
6. Run `terraform apply` to deploy the OCI project. Type `yes` to confirm (takes about 2-5 minutes).
7. After deployment, note the `oci_vpn_ip_tunnel1` output (e.g., `150.136.200.108`) for use in the next steps.
8. Retrieve the shared secret in the OCI Console:
   - Go to **Networking > Customer Connectivity > Site-to-Site VPN**.
   - Select the connection named `ipsec-<environment_name>-<location>-to-aws-001` (e.g., `ipsec-cabbage-usashburn-to-aws-001`).
   - Click **View** next to Configuration details.
   - Click ... to the right of the tunnel and select view shared secret (e.g., `abc123...`). Be sure to select the tunnel with the correct VPN IP address that was displayed in the Terraform output.

### Step 6: Update AWS Configuration with OCI VPN IP and Shared Secret
1. In the AWS project directory, open the `terraform.tfvars` file in your editor.
2. Update the `oci_vpn_ip_tunnel1` field with the `oci_vpn_ip_tunnel1` value from step 5 (e.g., `150.136.200.108`).
3. Update the `shared_secret_oci` field with the shared secret from step 5 (e.g., `abc123...`).
4. Save the file.
5. In the terminal, run `terraform apply` to apply the updates. Type `yes` to confirm (takes about 2-5 minutes).

### Step 7: Switch the Customer Gateway in the AWS Console
1. Go to the AWS Console: **VPC > Virtual private network (VPN) > Site-to-Site VPN connections**.
2. Select the VPN connection named `vpn-<environment_name>-<location>-to-oci`.
3. Click **Actions > Modify VPN connection**.
4. In the "Customer Gateway" section, change the Customer Gateway from `cgw-<environment_name>-<location>-oci-temp` to `cgw-<environment_name>-<location>-oci` using the dropdown menu.
5. Click **Save changes** to save the changes.
6. Wait for the VPN connection state to change from `modifying` to `available` in the AWS Console (takes a few minutes). The tunnel should come up after a few minutes (up to 15 minutes could be expected).

### Step 8: Sync Terraform State with Deployed State (Remove State)
1. In the terminal, run `terraform state rm aws_vpn_connection.aws_to_oci_vpn` to remove the VPN connection from the state (first step to sync Terraform state with deployed state).

### Step 9: Sync Terraform State with Deployed State (Import State)
1. Go to the AWS Console: **VPC > Virtual private network (VPN) > Site-to-Site VPN connections**.
2. Select the VPN connection named `vpn-<environment_name>-<location>-to-oci` and note the VPN connection ID (e.g., `vpn-12345678`) from the details pane.
3. In the AWS project terminal, run `terraform import aws_vpn_connection.aws_to_oci_vpn <vpn-id>` (replace `<vpn-id>` with the ID, e.g., `terraform import aws_vpn_connection.aws_to_oci_vpn vpn-12345678`).

### Step 10: Sync Terraform State with Deployed State (Update Configuration and Redeploy)
1. Open the `ipsec-oci.tf` file in your editor.
2. In the `aws_vpn_connection.aws_to_oci_vpn` resource, uncomment the line `customer_gateway_id = aws_customer_gateway.oci_customer_gateway.id` and comment out the line `customer_gateway_id = aws_customer_gateway.oci_customer_gateway_temp.id`.
3. Save the file.
4. In the AWS project terminal, run `terraform apply` to redeploy the project with the updated configuration. Type `yes` to confirm (no changes are actually made so this should be very quick).

### Step 11: Verify the Tunnel
1. Go to the AWS Console: **VPC > Site-to-Site VPN Connections**.
2. Select the `aws_to_oci_vpn` connection.
3. Check the "Tunnel Details" tab to confirm the tunnel status is "Up".

### Step 12: Connect to the AWS VM via RDP
1. Open your Remote Desktop client (e.g., Microsoft Remote Desktop).
2. Enter the public IP of the AWS VM from the `aws_vm_public_ip` output (e.g., `54.123.45.67`).
3. Use the username `Administrator` and the password retrieved in step 4.
4. Connect to the VM.

### Step 13: Verify Connectivity Between AWS and OCI VMs
1. From the AWS VM, open Command Prompt or PowerShell.
2. Ping the OCI VM’s private IP (e.g., `terraform output oci_vm_private_ip` in the OCI project, such as `10.1.1.10`).
3. In the OCI project, connect to the OCI VM via RDP using the public IP from the `oci_vm_public_ip` output.
4. From the OCI VM, ping the AWS VM’s private IP (e.g., `terraform output aws_vm_private_ip` in the AWS project, such as `10.3.1.10`).
5. Confirm bidirectional connectivity is successful.

### Step 14: Clean Up Resources
1. In the terminal, run `terraform destroy` to remove all resources. Type `yes` to confirm (takes about 1-2 minutes).
2. Repeat this step in the OCI project to clean up its resources.

## Potential Costs and Licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.