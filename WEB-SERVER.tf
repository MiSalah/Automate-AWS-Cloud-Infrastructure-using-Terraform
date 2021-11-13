# Configure the aws provider
provider "aws" {
    region = "us-east-1"
    access_key = "$access_key"
    secret_key = "$secret_key"
}


# 1. Create a VPC
resource "aws_vpc" "Production_VPC" {
    cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Production VPC"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "Internet_Gatewey" {
    vpc_id = aws_vpc.Production_VPC.id
    tags = {
      Name = "VPC Gateway"
    }
}

# 3. Create Custom Route Table
resource "aws_route_table" "Route_Table" {
  vpc_id = aws_vpc.Production_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gatewey.id
  }
  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.Internet_Gatewey.id
  }
  tags = {
    Name = "Production Route table"
  }
}

# 4. Create a Subnet
resource "aws_subnet" "Production_Subnet" {
    vpc_id = aws_vpc.Production_VPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "Production Subnet"
    }
}

# 5. Associate subnet with Route table

resource "aws_route_table_association" "Subnet_route_table" {
    subnet_id = aws_subnet.Production_Subnet.id
    route_table_id = aws_route_table.Route_Table.id
    tags = {
        Name = "Subnet & Route table Association"
    }
  
}

# 6. Create Security Group to enable 22, 80, 443 ports (ssh,http,https)
# 7. Create a network Interface with an ip address in the subnet that was created in step 4
# 8. Assign an elastic ip address to the network interface created in step 7
# 9. Create ubuntu server and install & enable apache2

