# Configure the aws provider
provider "aws" {
    region = "us-east-1"
    access_key = "$access_key"
    secret_key = "$secrey_key"
}