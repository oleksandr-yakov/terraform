#!/bin/bash
yum -y update
yum -y install httpd
myip=$(curl http://checkip.amazonaws.com)
echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform!"  >  /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
