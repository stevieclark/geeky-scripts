#!/bin/bash

########################################################
#Create Mysql Database
#######################################################
echo -n "Create Mysql Database? [y,n]"
read input

# did we get an input value?
if [ "$input" == "" ]; then
   echo "Aborted"       
   exit 1

# was it a y or a yes?
elif [[ "$input" == "y" ]] || [[ "$input" == "yes" ]]; then
   echo "Creating Mysql database"

# treat anything else as a negative response
else
   echo "No database required"
   exit 1
fi

# ask for the database username
echo -n 'Enter username: '
read db
DBNAME=$(echo $db)

# generates a random pwd
PASSWD=$(openssl rand -base64 14)

USER="$(echo $db)"


# MYSQL commands to create the database

mysql -uroot -e "CREATE DATABASE $DBNAME;"
mysql -uroot -e "CREATE USER "$USER"@"localhost" IDENTIFIED BY \"${PASSWD}\";"
mysql -uroot -e "GRANT ALL PRIVILEGES ON ${USER}.* TO '${DBNAME}'@'localhost';"
mysql -uroot -e "FLUSH PRIVILEGES;"


echo Database Setup Complete!
echo =============================
echo =database connection details=
echo =============================
echo -n "username: $USER"
echo
echo -n "pw: $PASSWD"
echo
echo =============================
