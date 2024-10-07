#!/bin/bash
yum -y update
yum -y install httpd
myip=$(curl http://checkip.amazonaws.com)

cat <<EOF > /var/www/html/index.html
<html>
<h2>Using dynamic external files of Terraform <font color="blue"> </font></h2><br>
Owner ${owner_name} create ec2 ${server_name} with ip: ${elastic_ip} write if you have a problem to ${owner_email}><br>

%{ for x in companys_name ~}
<br>
Owner ${owner_name} will work in ${x} using this address ${owner_email}<br>
%{ endfor ~}

</html>
EOF


sudo service httpd start
chkconfig httpd on
