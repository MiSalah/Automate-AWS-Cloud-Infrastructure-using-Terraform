#!/bin/nbash
sudo apt-get update -y
sudo apt-get install apache2 -y
sudo systemctl start apache2 
sudo bash -c 'echo A Web Server established using Terraform > /var/www/html/index.html'
