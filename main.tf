# Configure the aws provider
provider "aws" {
    region = "us-east-1"
    access_key = "$access_key"
    secret_key = "$secret_key"
}

# Create an EC2 Instance
resource "aws_instance" "ubuntu-server" {
    ami = " ami-083654bd07b5da81d" # The ami id from my aws account
    instance_type = "t2.micro" 

    tags = {
      "From" = "Terraform"
    }
  
}

# Create a VPC 

resource "aws_vpc" "vpc_prod" {
    cidr_block = "192.168.0.0/16"
    tags = {
      Name = "production_vpc"
    }
}

#Creating two subnets within our vpc

resource "aws_subnet" "subnet-01" {
    vpc_id = aws_vpc.vpc_prod.id # taking the id from the vpc after its creation
    cidr_block = "192.168.1.0/24"

    tags = {
      Name = "Production-subnet"
    }
}

resource "aws_subnet" "subnet-02" {
    vpc_id = aws_vpc.vpc_prod.id
    cidr_block = "192.168.2.0/24"

    tags = {
      Name = "test-subnet"
    }
}
