#!/bin/bash

#
# Restores the database backup if it is not intact
#

# is database intact, if yes, then return
# using code from healthcheck.sh
ISMONGOALIVE=$(mongo --host $MONGO_HOST:$MONGO_PORT --eval 'db.getMongo().getDBNames().indexOf("rocketchat")' --quiet)
if [ $ISMONGOALIVE -lt 0 ]; then
    echo "Database rocketchat does not exist"
else
	echo "Database rocketchat exists" 
	exit 0
fi

# get latest backup
FILE="/backups/$(ls /backups | grep "backup-.*\.7z" | tail -1)"
echo "Latest database backup file found: $FILE"

# extract
if [ -n "$(ls -A /dump/)" ]; then
	echo "/dump/ folder is not empty, clearing contents"
	rm -rd /dump/*
fi

echo "Extracting $FILE to dump/"
7za x "$FILE" -o/dump

# restore DB
echo "Running mongorestore"
mongorestore --host db --db rocketchat --drop --noIndexRestore
