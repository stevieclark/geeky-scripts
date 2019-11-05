#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "usage = <domain.tld>"
    exit 1
fi

WEB_ROOT_DIR=/var/www/html/$1/www/
host=${host:-localhost}


#grabs the wordpress files, unzips and moves them into site directory
curl -LO https://wordpress.org/latest.zip
unzip latest.zip
mv wordpress/* $WEB_ROOT_DIR

#cleanup
rm -rf wordpress
rm latest.zip

#read database details for wp-config.php
read -p "enter database username: " dbuser
read -p "enter database name: " dbname
read -p "enter database password: " dbpass
read -p "enter database hostname [Enter for localhost]: " host


#adds datbase details to wp-config.php
cp $WEB_ROOT_DIR/wp-config-sample.php $WEB_ROOT_DIR/wp-config.php
sed -i "s/username_here/$dbuser/g" $WEB_ROOT_DIR/wp-config.php
sed -i "s/database_name_here/$dbname/g" $WEB_ROOT_DIR/wp-config.php
sed -i "s/password_here/$dbpass/g" $WEB_ROOT_DIR/wp-config.php
sed -i "s/localhost/$host/g" $WEB_ROOT_DIR/wp-config.php
