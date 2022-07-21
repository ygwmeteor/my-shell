#!/bin/sh

# aim to backup the Jira/Confluence/Crowd database
# crontab run at 7:00PM (UTC+8) every day
# procedure: first backup all the data, then check if 60 days ago backup files exist, then delete prior
# created by Gaowei Yuan at 2019-05-29

# cd $BACKDIR

YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
HOUR=`date +%H`

BACKDIR="/var/atlassian/application-data/jira/export/"
BACKDIRconf="/var/atlassian/application-data/confluence/backups/"
BACKDIRcrowd="/var/atlassian/application-data/crowd-home/backups/"
PATH1="/var/atlassian/application-data/backup-log/Database_backup"
LOGFILE=$PATH1-$YEAR-$MONTH-log


echo "==========================================================" >> $LOGFILE
echo $(date +"%Y-%m-%d %H:%M:%S")"  Database backup begin" >> $LOGFILE


JIRA=$BACKDIR$YEAR-$MONTH-$DAY-jira-db-backup-$HOUR\.tar.gz
CONFLUENCE=$BACKDIRconf$YEAR-$MONTH-$DAY-confluence-db-backup-$HOUR\.tar.gz
CROWD=$BACKDIRcrowd$YEAR-$MONTH-$DAY-crowd-db-backup-$HOUR\.tar.gz



# Backup Jira DB
cd /tmp/
mysqldump -ujira -pnb@233 jiradb >/tmp/jiradb.sql

if [ $? -eq 0 ]
then
	tar zcvf $JIRA jiradb.sql >> /dev/null 2>&1
	echo "Jira Database  backup finished at "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE
	rm -rf /tmp/jiradb.sql
else
	echo "Jira Database backup failed at "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE

fi

# Backup Confluence DB
sleep 5m

cd /tmp/
mysqldump -uconfluence -pnb@233 confluence >/tmp/confluence.sql

if [ $? -eq 0 ]
then
	tar zcvf $CONFLUENCE confluence.sql >> /dev/null 2>&1
	echo "Confluence Database  backup finished at "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE
	rm -rf /tmp/confluence.sql
else
	echo "Confluence Database backup failed at "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE

fi

# Backup Crowd DB

cd /tmp/
mysqldump -ucrowd -pnb@233 crowd >/tmp/crowd.sql

if [ $? -eq 0 ]
then
	tar zcvf $CROWD crowd.sql >> /dev/null 2>&1
	echo "Crowd Database  backup finished at "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE
	rm -rf /tmp/crowd.sql
else
	echo "Crowd Database backup failed at "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE

fi


#Delete backup files backuped 2 months ago
if [ $DAY = '01' ]
then
	find $BACKDIR -mtime +62 -name "*.*" -exec rm -rf {} \;
	echo "  Delete Old Jira Backup files Successful!" >> $LOGFILE

	find $BACKDIRconf -mtime +62 -name "*.*" -exec rm -rf {} \;
	echo " Delete Old Confluence Backup files Successful!" >> $LOGFILE

	find $BACKDIRcrowd -mtime +62 -name "*.*" -exec rm -rf {} \;
	echo " Delete Old Crowd Backup files Successful!" >> $LOGFILE

fi



