#!/bin/bash

sudo yum install httpd -y

sudo apachectl start
sudo systemctl enable httpd

sudo systemctl stop firewalld
sudo systemctl disable firewalld

#$ The commands below don't worked on cloud-init script for OCI Oracle-Linux-7.9-2020.10.26-0
#sudo firewall-cmd --zone=public --add-service=http
#sudo firewall-cmd --permanent --zone=public --add-service=http

cd /var/www/html/

sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/u8j40_AS-7pRypC5boQT24w5QFPDTy-0j27BWBOfmsxbERTiuDtJQBIqfcsOH81F/n/idqfa2z2mift/b/bootcamp-oci/o/oci-f-handson-modulo-compute-website-files.zip

sudo unzip oci-f-handson-modulo-compute-website-files.zip

sudo chown -R apache:apache /var/www/html

sudo rm -rf oci-f-handson-modulo-compute-website-files.zip

# Inclui host e IP na pagina index.html
sudo sed -i '119i '"<h1><br><FONT COLOR="#FF0000">ip: $(hostname -i)</FONT><br></h1>"'' /var/www/html/index.html