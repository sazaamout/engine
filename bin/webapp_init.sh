#!/bin/bash


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

aws s3 cp s3://$s3_destination/db/mydbdump.sql ~/  --profile dev
mysql -h $db_endpoint -u $db_username -p$db_password -D $db_name < ~/mydbdump.sql 

echo "database was populated with data successfuly"
