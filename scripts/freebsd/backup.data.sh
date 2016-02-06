#!/usr/local/bin/bash

LOGFILE="/var/log/backup.log"
bakpath="/mnt/backup"
count=7

function do_backup {
	#set source
	src=$1
	#set destination
	dest=$bakpath/$2
	#delete the last increment if it exists
	[ -d $dest.$count ] && rm -fr $dest.$count
	#move increments
	for (( i = count - 1; i > 0; i-- )); do
		[ -d $dest.$i ] && mv $dest.$i $dest.$(($i+1))
	done
	mv $dest $dest.1
	opt="-av -zz --delete --link-dest=$dest.1"
	rsync $opt $src $dest
}

echo "`date`	Starting backup for: BACKUP" | tee -a $LOGFILE
do_backup /mnt/data/backup/ backup

echo "`date`	Starting backup for: DOCUMENTS" | tee -a $LOGFILE
do_backup /mnt/data/documents/ documents

echo "`date`	Starting backup for: PICTURES" | tee -a $LOGFILE
do_backup /mnt/data/pictures/ pictures

#echo "`date`	Starting backup for: STORAGE" | tee -a $LOGFILE
#do_backup /mnt/storage/ storage

echo "`date`	Starting backup for: REPOS" | tee -a $LOGFILE
do_backup /mnt/data/repos/ repos

echo "`date`	Starting backup for: WORK" | tee -a $LOGFILE
do_backup /mnt/data/work/ work
