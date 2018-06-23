#!/bin/bash

echo "database username"
read db_user

echo "database password"
read db_password

echo "database name"
read db_name

echo "database endpoint"
read db_endpoint

aws s3 cp s3://$s3_destination/db/mydbdump.sql ~/  --profile dev
mysql -h $db_endpoint -u $db_username -p$db_password -D $db_name > ~/mydbdump.sql 

#
