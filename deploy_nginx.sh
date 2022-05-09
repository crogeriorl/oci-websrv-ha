#!/bin/bash

sudo yum install nginx -y

#sudo systemctl start nginx
#sudo systemctl enable nginx

#$ The commands below don't worked on cloud-init script for OCI Oracle-Linux-7.9-2020.10.26-0
#sudo firewall-cmd --zone=public --add-service=http
#sudo firewall-cmd --permanent --zone=public --add-service=http

sudo systemctl stop firewalld
sudo systemctl disable firewalld


# Inclui host e IP na pagina index.html

sudo sed -i '24i '"<h3><br><FONT COLOR="#0000FF">Load Balancer + H.A. / $(hostname -f) - IP: $(hostname -i)</FONT><br></h3>"'' /var/www/html/index.nginx-debian.html