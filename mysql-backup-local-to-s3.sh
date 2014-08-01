#!/bin/bash

# Script to dump a MySQL database and gzip it into the SAVEDIR then upload to Amazon S3
# Must have s3cmd installed and preconfigured with valid AWS IAM credentials

exec &>> ~/DatabaseBackup.log

USER="DB USERNAME HERE"
PASSWORD="DB PASSWORD HERE"
DATABASE="DB NAME HERE"
HOST="localhost OR REMOTE HOST NAME HERE"
PORT="3306 OR OTHER PORT NUMBER HERE"
SAVEDIR="~/DB BACKUP PATH HERE"
S3BUCKET="YOUR S3 BUCKET NAME HERE"

date '+%c'
echo "Beginning $DATABASE Backup"

# Dump MySQL database, compress using gzip and append the date to the filename
mysqldump -P $PORT -h $HOST -u $USER --password=$PASSWORD --default-character-set=utf8 $DATABASE -c | /bin/gzip -9 > $SAVEDIR/$DATABASE-$(date '+%Y%m%d-%H').sql.gz
# Need to do some error checking here

# Sync backup to Amazon S3 bucket
s3cmd sync --recursive $SAVEDIR s3://$S3BUCKET/$DATABASE/
# Need to do some error checking here
echo "Backup Uploaded to Amazon S3 Bucket: $S3BUCKET/$DATABASE"

# Optional: Delete the backup file from the server after uploading to S3
# rm $SAVEDIR/*