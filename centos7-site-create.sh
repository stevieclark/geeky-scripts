#!/bin/bash

##################################################
#Config checks, handy for first time installations
##################################################

#checks if the httpd.conf has the appropriate line included to enable virtual hosts
grep -qF "Include /etc/httpd/sites-enabled/*.conf" /etc/httpd/conf/httpd.conf
if
        [[ $? != 0 ]]; then echo -e "\nErr: Please add the following line to /etc/httpd/conf/httpd.conf;\n'Include /etc/httpd/sites-enabled/*.conf'\n"
        exit 1
fi

#creates virtual hosts directories
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled

##################################################

name=$1
mkdir -p /var/www/html/$name/www
WEB_ROOT_DIR=/var/www/html/$name/www
email='webmaster@localhost'
sitesEnable='/etc/httpd/sites-enabled/'
sitesAvailable='/etc/httpd/sites-available/'
sitesAvailabledomain=$sitesAvailable$name.conf
echo "Creating a vhost for $sitesAvailabledomain with a webroot $WEB_ROOT_DIR"

### create virtual host rules file
echo "
    <VirtualHost *:80>
      ServerAdmin $email
      ServerName $name
      ServerAlias www.$name
      DocumentRoot $WEB_ROOT_DIR
      <Directory $WEB_ROOT_DIR/>
        Options Indexes FollowSymLinks
        AllowOverride all
      </Directory>
    </VirtualHost>" > $sitesAvailabledomain

ln -s /etc/httpd/sites-available/$name.conf /etc/httpd/sites-enabled/

echo -e $"\nNew Virtual Host Created\n"

service httpd reload

echo 'Site Conf Created Successfully'

useradd $2
echo "$2:$3" | chpasswd
usermod -d /var/www/html/$name/ $2

cp /var/www/html/readme.html /var/www/html/$name/www/

chown -R $2:apache /var/www/html/$name/
