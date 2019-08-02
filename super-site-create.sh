#!/bin/bash

######################################################
#Script input check for the correct number of
#		arguments to process
######################################################

if [ "$#" -ne 3 ]; then
    echo "usage = <domain.tld> <username> <password>"
    exit 1
fi

######################################################

#variables
        
name=$1
WEB_ROOT_DIR=/var/www/html/$name/www
email=${3-'webmaster@localhost'}
sitesEnable='/etc/apache2/sites-enabled/'
sitesAvailable='/etc/apache2/sites-available/'
sitesAvailabledomain=$sitesAvailable$name.conf

#creates virtual host

echo "Creating a vhost for $sitesAvailabledomain with a webroot $WEB_ROOT_DIR"

mkdir -p /var/www/html/$name/www

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
#			user.
#######################################################
cp /var/www/html/readme.html /var/www/html/$name/www/.

chown -R $2:www-data /var/www/html/$name/

#######################################################
#Calls Database Creation Script
#######################################################
#source /root/dbtest.sh

function dbcreate {
# ask for the database username
echo -n 'Enter username: '
read db
DBNAME=$(echo $db)

# generates a random pwd
PASSWD=$(openssl rand -base64 14)

USER="$(echo $db)"

# MYSQL commands to create the database

mysql -uroot -e "CREATE DATABASE $DBNAME;"
mysql -uroot -e "CREATE USER '$USER'@'localhost' IDENTIFIED BY \"${PASSWD}\";"
mysql -uroot -e "GRANT ALL PRIVILEGES ON ${USER}.* TO '${DBNAME}'@'localhost';"
mysql -uroot -e "FLUSH PRIVILEGES;"


echo Database Setup Complete!
echo =============================
echo =database connection details=
echo =============================
echo -n "database name: $USER"
echo
echo -n "username: $USER"
echo
echo -n "pw: $PASSWD"
echo
}

#db create prompt

echo -n "Create Mysql Database? [y,n]"
read inputdb

# did we get an input value?
if [ "$inputdb" == "" ]; then
   echo "Aborted"       
   exit 1

# was it a y or a yes?
elif [[ "$inputdb" == "y" ]] || [[ "$inputdb" == "yes" ]]; then
   echo "Creating Mysql database" && dbcreate

# treat anything else as a negative response
else
   echo "No database required"
   exit 1
fi


#######################################################
#ask user if they want to install wordpress files
#######################################################

#grabs the wordpress files, unzips and moves them into site directory

function wpinstall {
echo Downloading Wordpress
echo
curl -LO --progress-bar https://wordpress.org/latest.zip
echo Unzipping Files
unzip -q latest.zip | 2&>1 > /dev/null
mv wordpress/* $WEB_ROOT_DIR/

#cleanup
rm -rf wordpress
rm latest.zip

#read database details for wp-config.php
#read -p "enter database username: " dbuser
#read -p "enter database name: " dbname
#read -p "enter database password: " dbpass
read -p "enter database hostname [Enter for localhost]: " host

host=${host:-localhost}

#adds datbase details to wp-config.php
cp $WEB_ROOT_DIR/wp-config-sample.php $WEB_ROOT_DIR/wp-config.php
sed -i "s/username_here/$USER/g" $WEB_ROOT_DIR/wp-config.php
sed -i "s/database_name_here/$USER/g" $WEB_ROOT_DIR/wp-config.php
sed -i "s/password_here/$PASSWD/g" $WEB_ROOT_DIR/wp-config.php
sed -i "s/localhost/$host/g" $WEB_ROOT_DIR/wp-config.php
echo
echo -n "Wordpress Setup Complete"
echo
}

while true; do
read -p "Would you like to install wordpress to this webspace? (y/n): " yn

case $yn in
	[Yy]* ) wpinstall; break;;
	[Nn]* ) exit;;
	* )  echo "Please enter y/n";;
esac
done



echo
echo =====================================
echo "=database connection details (again)="
echo =====================================
echo -n "hostname: $host"
echo
echo -n "database name: $USER"
echo
echo -n "username: $USER"
echo
echo -n "pw: $PASSWD"
echo

