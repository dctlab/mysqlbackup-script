
#!/bin/bash
# Shell script to backup MySQL database

# Set these variables
MyUSER="backup_user"	# DB_USERNAME
MyPASS="backup_user_password"	# DB_PASSWORD
MyHOST="127.0.0.1"	# DB_HOSTNAME

# Backup Dest directory
DEST="home/user/backup/db" # /home/username/backups/DB

# Email for notifications
EMAIL="mail@googlemail.com"

# How many days old files must be to be removed
DAYS=1

# Linux bin paths
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

# Get date in dd-mm-yyyy format
NOW="$(date +"%d-%m-%Y_%s")"

# Create Backup sub-directories
MBD="$DEST/$NOW/mysql"
install -d $MBD

# DB skip list
SKIP="information_schema
another_one_db"

# Get all databases
DBS="$($MYSQL -h $MyHOST -u $MyUSER -p$MyPASS -Bse 'show databases')"

# Archive database dumps
for db in $DBS
do
    skipdb=-1
    if [ "$SKIP" != "" ];
    then
		for i in $SKIP
		do
			[ "$db" == "$i" ] && skipdb=1 || :
		done
    fi
 
    if [ "$skipdb" == "-1" ] ; then
    	FILE="$MBD/$db.sql"
	$MYSQLDUMP -h $MyHOST -u $MyUSER -p$MyPASS $db > $FILE
    fi
done

# Archive the directory, send mail and cleanup
cd $DEST
tar -cf $NOW.tar $NOW
$GZIP -9 $NOW.tar

echo "MySQL backup is completed! Backup name is $NOW.tar.gz" | mail -s "MySQL backup" $EMAIL
rm -rf $NOW

# Remove old files
find $DEST -mtime +$DAYS -exec rm -f {} \;
