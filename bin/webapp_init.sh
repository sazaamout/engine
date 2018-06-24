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
S3_NME=$(cat /etc/database.php | grep s3_bucket_name | cut -d"=" -f2 | grep -oP [a-zA-Z0-9\._-]+)

echo $DB_USR 
echo $DB_PWD 
echo $DB_HST 
echo $DB_NME
echo $S3_NME
exit

#echo "What is the database username: "
#read db_username

#echo "what is the database password:"
#read db_password

#echo "what is the database name:"
#read db_name

#echo "how about the database endpoint:"
#read db_endpoint

#echo "the name of the configurtaion s3 bucket name:"
#read s3_destination

#echo "and finally, autoscaling name:"
#read autoscaling_name

# populat the database with the sample data i created
aws s3 cp s3://$S3_NME/db/mydbdump.sql ~/ 
if [ $? -ne 0 ]; then
  echo "cannot download file from s3."
  exit 1
else
  echo "database file was downloaded"
fi
  
mysql -h $DB_HST -u $DB_USR -p$DB_PWD -D $DB_NAME < ~/mydbdump.sql 
if [ $? -ne 0 ]; then
  echo "could not populate database, somethin went wrong"
  exit 1
else 
  echo "database was populated with data successfuly"
fi

# starting the autoscaling group
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name $AS_NME \
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
