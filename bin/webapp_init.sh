#!/bin/bash

#
# this script should be ran once and deleted
#
#

# collect data from client
echo "What is the database username: "
read db_username

echo "what is the database password:"
read db_password

echo "what is the database name:"
read db_name

echo "how about the database endpoint:"
read db_endpoint

echo "the name of the configurtaion s3 bucket name:"
read s3_destination

echo "and finally, autoscaling name:"
read autoscaling_name

# populat the database with the sample data i created
aws s3 cp s3://$s3_destination/db/mydbdump.sql ~/ 
if [ $? -ne 0 ]; then
  echo "cannot download file from s3."
  exit 1
else
  echo "database file was downloaded"
fi
  
mysql -h $db_endpoint -u $db_username -p$db_password -D $db_name < ~/mydbdump.sql 
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
