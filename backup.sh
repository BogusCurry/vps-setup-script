#!/bin/bash
# *************************************************************
# file: mysqldump.sh
# date: 2007-07-04 00:22
# author: (c) by Marko Schulz - <info@tuxnet24.de>
# description: Get a mysqldump of all mysql databases.
# *************************************************************

# name of database user ( must have LOCK_TABLES rights )...
dbUsername='xxx'

# password of database user...
dbPassword='yyy'

# path to backup directory...
dbBackup='/data/dumps'

# delete old dumps
deleteOld=false

# *************************************************************

# get current date ( YYYY-MM-DD )...
date=$( date +%Y%m%d-%H%M%S )

# create backup directory if not exists...
[ ! -d "$dbBackup" ] && mkdir -p $dbBackup

# delete all old mysqldumps...
if $deleteOld ; then
    find $dbBackup -type f -name '*.sql.gz' -exec rm -rf {} ';' >/dev/null 2>&1
fi

# loop all databases...
for db in $( mysql -u $dbUsername --password=$dbPassword -Bse "show databases" ); do

    if [[ "$db" != "mysql" ]] && [[ "$db" != "test" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] ; then
        # get mysqldump of current database...
        fullPath="$dbBackup/$db-$date.sql.gz"
        echo "Dumping $db into $fullPath ..."
        mysqldump -u $dbUsername --password=$dbPassword --opt --databases $db | gzip -9 > $fullPath
    fi

done

# backup data sites
backupPath="/root/data/$date.tar.gz"
tar -czhpf $backupPath /data --exclude "vendor" --exclude "node_modules" --exclude "/data/phpMyAdmin*" \
    --exclude "web/assets/*"