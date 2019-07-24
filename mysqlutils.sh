#!/bin/bash

#loop script until user inputs quit

until [ "$COM" == "quit" ]
do

 echo
 echo -e "usage=(\nDELdb <database>\nDELusr <username>\nSHOWdbs\nSHOWusrs\nOPTIMISE <database>\nQuit\n)"
 echo
 read -p "which command would you like to run?: " COM DB

#take user input and convert to lowercase
 COM=$(echo "$COM" | awk '{print tolower($0)}')

#database variables
 DBNAME=$(echo $DB)
 USR=$(echo $DB)

#no input
 if [ "$COM" == "" ]; then
    echo "Aborted"       
    exit 1
 elif

#DELdb
   [ "$COM" = "deldb" ]; then
   read -rp "Really Delete database $DB? [y/n]: " input
    if [[ "$input" == "y" ]] || [[ "$input" == "yes" ]]; then
     mysql -uroot -e "drop database $DBNAME;"
    fi

 elif

#DELusr
   [[ "$COM" = "delusr" ]]; then
   read -rp "Really Delete user $USR? [y/n]: " input
    if [[ "$input" == "y" ]] || [[ "$input" == "yes" ]]; then
     mysql -uroot -e "DROP USER '$USR'@'localhost';"
    fi
 elif
#SHOWdbs
   [[ "$COM" = "showdbs" ]]; then
   echo "Showing Databases"
   mysql -uroot -e "SHOW DATABASES;"
 elif
 #SHOWusrs
   [[ "$COM" = "showusrs" ]]; then
   echo "Showing Users"
   mysql -uroot -e "SELECT User, Host, Password FROM mysql.user;"
 elif
#OPTIMISE
   [[ "$COM" = "optimise" ]]; then
   echo -e "Optimising tables on $DB...\n"
   mysqlcheck -o $DBNAME
 fi
done

