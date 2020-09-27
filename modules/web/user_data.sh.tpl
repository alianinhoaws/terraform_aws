#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`


cat <<EOF > /var/www/html/index.html
<html>

<h2>Build by <font color="green"> ${name} ${surname} My Ip is: $myip </font></h2><br>
%{ for x in names ~}
Thanks to ${x} <br>
%{ endfor ~}

</html>
EOF

sudo service httpd start
chkconfig httpd on

