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