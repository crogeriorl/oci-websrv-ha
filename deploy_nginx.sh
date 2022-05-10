#!/bin/bash


sudo yum install nginx -y


# The commands below don't worked on cloud-init script for OCI Oracle-Linux-7.9-2020.10.26-0

#sudo firewall-cmd --zone=public --add-service=http
#sudo firewall-cmd --permanent --zone=public --add-service=http
# Don't do this in production sites!
sudo systemctl stop firewalld
sudo systemctl disable firewalld


# Install Nginx demo files on base directories

cd /etc/nginx/conf.d
sudo rm -rf hello.conf
sudo wget https://raw.githubusercontent.com/crogeriorl/NGINX-Demos/master/nginx-hello/hello.conf

cd /usr/share/nginx/html/
# Put your website or app here!
sudo mv index.html index.html.orig
sudo rm -rf index.html
sudo wget https://raw.githubusercontent.com/crogeriorl/NGINX-Demos/master/nginx-hello/index.html


# Insert some text, host and IP within index.html

sudo sed -i '88i '"<h1><br><FONT COLOR="#0000FF"><center>## OCI - Always Free: 2 Webservers w/ Load Balancer + H.A.</center></FONT><br></h3>"'' /usr/share/nginx/html/index.html
sudo sed -i '88i '"<h3><br><FONT COLOR="#0000FF"><center>$(hostname -f) - IP: $(hostname -i)</center></FONT><br></h3>"'' /usr/share/nginx/html/index.html


# Initialize NGINX service

sudo systemctl start nginx
sudo systemctl enable nginx
