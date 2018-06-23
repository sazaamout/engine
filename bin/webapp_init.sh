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

echo "and finally, the s3 bucket name:"
read s3_destination

echo "and finally, the s3 bucket name:"
read autoscaling_name

# populat the database with the sample data i created
aws s3 cp s3://$s3_destination/db/mydbdump.sql ~/  --profile dev
mysql -h $db_endpoint -u $db_username -p$db_password -D $db_name < ~/mydbdump.sql 

echo "database was populated with data successfuly"

# starting the autoscaling group
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name $autoscaling_name
    --min-size 2 \
    --max-size 5 \
    --desired-capacity 2
    --profile dev

echo "your webapp is launched, should be ready in few minutes"
