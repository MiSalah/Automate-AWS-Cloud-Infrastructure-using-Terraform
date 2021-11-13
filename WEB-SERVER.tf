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

# 6. Create Security Groups to enable 22, 80, 443 ports (ssh,http,https)

resource "aws_security_group" "Allow_web" {
    name = "allow_web_traffic"
    description = "Allow inbound traffic for ssh, http, https" 
    vpc_id = aws_vpc.Production_VPC.id

    ingress {
        description = "allow http traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
    ingress {
        description = "allow https traffic"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "allow ssh"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "Inbound web traffic to our web server"
    }
}

# 7. Create a network Interface with an ip address in the subnet that was created in step 4

resource "aws_network_interface" "web_server_NIC" {
    subnet_id = aws_subnet.Production_Subnet.id
    private_ips = [ "10.0.1.50" ]
    security_groups = [aws_security_group.Allow_web.id]
}

# 8. Assign an elastic ip address to the network interface created in step 7

resource "aws_eip" "elastic_ip" {
    vpc         = true
    network_interface = aws_network_interface.web_server_NIC.id
    associate_with_private_ip = "10.0.1.50"
    
    depends_on = [
      aws_internet_gateway.Internet_Gatewey
    ]
}

# 9. Create ubuntu server and install & enable apache2

resource "aws_instance" "ubuntu_web_server" {
    ami = "ami-083654bd07b5da81d"
    instance_type = t2.micro
    availability_zone = us-east-1a
    key_name = "my-key"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web_server_NIC
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt get update -y
                sudo install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo A Web Server established using Terraform > /var/www/html/index.html'
                EOF
    
    tags = {
      Name = "Ubuntu Apache Web-server "
    }

}


