# Configure the aws provider
provider "aws" {
    region = "us-east-1"
    access_key = "$access_key"
    secret_key = "$secret_key"
}

# 1. Create a VPC
# 2. Create Internet Gateway
# 3. Create Custom Route Table
# 4. Create a Subnet
# 5. Associate subnet with Route table
# 6. Create Security Group to enable 22, 80, 443 ports (ssh,http,https)
# 7. Create a network Interface with an ip address in the subnet that was created in step 4
# 8. Assign an elastic ip address to the network interface created in step 7
# 9. Create ubuntu server and install & enable apache2

