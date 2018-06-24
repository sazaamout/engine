#!/bin/bash

#
# this script should be ran once and deleted
#
#

# collect data from client
DB_USR=$(cat /etc/database.php | grep db_username    | cut -d"=" -f2 | grep -oP [a-zA-Z0-9\._-]+)
DB_PWD=$(cat /etc/database.php | grep db_password    | cut -d"=" -f2 | grep -oP [a-zA-Z0-9\._-]+)
DB_HST=$(cat /etc/database.php | grep db_endpoint    | cut -d"=" -f2 | grep -oP [a-zA-Z0-9\._-]+)
DB_NME=$(cat /etc/database.php | grep db_name        | cut -d"=" -f2 | grep -oP [a-zA-Z0-9\._-]+)
S3_NME=$(cat /etc/database.php | grep s3_name        | cut -d"=" -f2 | grep -oP [a-zA-Z0-9\._-]+)


echo "what is the autoscaling group name?"
echo "hinst: you can get it from the terraform output"
read autoscaling_name

# populat the database with the sample data i created
aws s3 cp s3://$S3_NME/db/mydbdump.sql ~/ 
if [ $? -ne 0 ]; then
  echo "cannot download file from s3."
  exit 1
else
  echo "database file was downloaded"
fi
  
mysql -h $DB_HST -u $DB_USR -p$DB_PWD -D $DB_NME < ~/mydbdump.sql 
if [ $? -ne 0 ]; then
  echo "could not populate database, somethin went wrong"
  exit 1
else 
  echo "database was populated with data successfuly"
fi

# starting the autoscaling group
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name $autoscaling_name \
    --min-size 2 \
    --max-size 5 \
    --desired-capacity 2 

if [ $? -ne 0 ]; then
  echo "could not trigger autoscaling to start, somethin went wrong"
  exit 1
else
  echo "your webapp is launched, should be ready in few minutes"
  exit 0
fi
