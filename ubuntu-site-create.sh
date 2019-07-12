#!/bin/bash

######################################################
#Script input check for the correct number of
#               arguments to process
######################################################

if [ "$#" -ne 3 ]; then
    echo "usage = <domain.tld> <username> <password>"
    exit 1
fi

######################################################

name=$1
mkdir -p /var/www/html/$name/www
WEB_ROOT_DIR=/var/www/html/$name/www
email=${3-'webmaster@localhost'}
sitesEnable='/etc/apache2/sites-enabled/'
sitesAvailable='/etc/apache2/sites-available/'
sitesAvailabledomain=$sitesAvailable$name.conf
echo "Creating a vhost for $sitesAvailabledomain with a webroot $WEB_ROOT_DIR"

######################################################
#creates virtual host file from the listed variables
######################################################
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
echo -e $"\nNew Virtual Host Created\n"

a2ensite $name
service apache2 reload

echo 'Site Conf Created Successfully'

useradd $2
echo "$2:$3" | chpasswd
usermod -d /var/www/html/$name/ $2

#######################################################
#copies over test page to check the provisioning of the
#webspace has worked and chowns the webspace to the new
#                       user.
#######################################################
cp /var/www/html/readme.html /var/www/html/$name/www/.
