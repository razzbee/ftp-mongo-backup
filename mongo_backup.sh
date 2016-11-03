#!/bin/bash

PERIOD=$1

if [ -z "${PERIOD}" ]; then
   PERIOD="daily"
fi


MONGO_DATABASE=""
APP_NAME="medianap"

MONGO_HOST="127.0.0.1"
MONGO_PORT="27017"
TIMESTAMP=`date +%Y-%m-%d`
MONGODUMP_PATH="/usr/bin/mongodump"
BACKUPS_DIR="/home/medianap/backups/mongodb"
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
FTP_SUBDIR_PATH="/private/mongodb/$PERIOD/mn_mongo_backup.tar.gz"    #/var/www/medianap-backups.com
 
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

#ftp -inv -u "ftp://$FTP_USERNAME:$FTP_PASSWORD@$FTP_HOST:$FTP_PORT/$FTP_DIR" $BACKUP_FILE_DEST

#ftp -niv $FTP_HOST <<EOD
#quote USER $FTP_USERNAME
#quote PASS $FTP_PASSWORD
#cd $FTP_DIR
#put $BACKUP_FILE_DEST
#quit
#EOD
