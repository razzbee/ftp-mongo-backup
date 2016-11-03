#!/bin/bash

PERIOD=$1

if [ -z "${PERIOD}" ]; then
   PERIOD="daily"
fi

#mongo dtabase name to backup
MONGO_DATABASE=""

#App Name , Needed
APP_NAME="MongoBackup"

#mongo connection info
MONGO_HOST="127.0.0.1"
MONGO_PORT="27017"
TIMESTAMP=`date +%Y-%m-%d`
MONGODUMP_PATH="/usr/bin/mongodump"

#Local Backup  Dir , needed 
BACKUPS_DIR="/home/backups/mongodb"

BACKUP_NAME="$APP_NAME-$TIMESTAMP.tar.gz"

BACKUP_FILE_DEST="$BACKUPS_DIR/$BACKUP_NAME"

if [ -f "${BACKUP_FILE_DEST}" ]; then 
  echo " ${PERIOD}ly already backed up"
 # exit
fi

#FTP DETAILS 
EXPORT_TO_FTP=true
FTP_HOST=""
FTP_PORT=21
FTP_USERNAME=""
FTP_PASSWORD=""
FTP_SUBDIR_PATH="/private/mongodb/$PERIOD/mongo_backup.tar.gz"    #/var/www/medianap-backups.com
 
# mongo admin --eval "printjson(db.fsyncLock())"
# $MONGODUMP_PATH -h $MONGO_HOST:$MONGO_PORT -d $MONGO_DATABASE
$MONGODUMP_PATH -d $MONGO_DATABASE
# mongo admin --eval "printjson(db.fsyncUnlock())"
 
  
mkdir -p $BACKUPS_DIR 
mv dump $BACKUP_NAME
tar -zvcf  $BACKUP_FILE_DEST $BACKUP_NAME
rm -rf $BACKUP_NAME

cd $BACKUPS_DIR

#FTP ACTIVITIES 
curl --ftp-create-dirs -T $BACKUP_FILE_DEST  -u $FTP_USERNAME:$FTP_PASSWORD  ftp://$FTP_HOST/$FTP_SUBDIR_PATH

