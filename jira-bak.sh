#!/bin/sh

# aim to backup the Jira home directory files
# crontab run at 8:00PM (UTC+8) every day
# procedure: first backup all the data, then check if 60 days ago backup files exist, then delete prior
# created by Gaowei Yuan at 2016-06-13
# modified by Gaowei Yuan at 2017-12-20

# cd $BACKDIR

YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`

BACKDIR="/var/atlassian/application-data/jira/export/"
BACKDIRconf="/var/atlassian/application-data/confluence/backups/"
PATH1="/var/atlassian/application-data/backup-log/Attachment_backup"
LOGFILE=$PATH1-$YEAR-$MONTH-log


RESOURCEPATH="/home/"    # add the path var to avoid the 'Removing leading / from member names tips'
RESOURCEDIR="/var/atlassian/application-data/jira/data"
RESOURCEDIRconf="/var/atlassian/application-data/confluence/attachments"


echo "--------------------------------------------" >> $LOGFILE
echo $(date +'%Y-%m-%d %H:%M:%S')" Attachment files backup begin" >> $LOGFILE


FILENAME=$BACKDIR$YEAR-$MONTH-$DAY-jira-data-backup.tar.gz
FILENAMEconf=$BACKDIRconf$YEAR-$MONTH-$DAY-confluence-attachments-backup.tar.gz



# backup the resources folder
cd $RESOURCEPATH
if [ $DAY = '01' ]
then
	tar zcvf $FILENAME $RESOURCEDIR >> /dev/null 2>&1
	echo "Jira Home Directory files backup finished at "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE
	tar zcvf $FILENAMEconf $RESOURCEDIRconf >> /dev/null 2>&1
	echo "Confluence Home Directory files backup finished at "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE
else
	tar zcvf $FILENAME $RESOURCEDIR -N $BACKDIR$YEAR-$MONTH-01-jira-data-backup.tar.gz >> /dev/null 2>&1
	echo "Jira Home Directory files backup finished at "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE
	tar zcvf $FILENAMEconf $RESOURCEDIRconf -N $BACKDIRconf$YEAR-$MONTH-01-confluence-attachments-backup.tar.gz >> /dev/null 2>&1
	echo "Confluence Home Directory files backup finished at "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE

fi


#Delete backup files backuped 2 months ago
if [ $DAY = '01' ]
then
	find $BACKDIR -mtime +62 -name "*.*" -exec rm -rf {} \;
	echo "Delete Old Jira Backup files Successful!" >> $LOGFILE

	find $BACKDIRconf -mtime +62 -name "*.*" -exec rm -rf {} \;
	echo "Delete Old Confluence Backup files Successful!" >> $LOGFILE
fi

# check the old backup file
#DBACKFILE=$BACKDIR$(date +%Y-%m-%d --date='20 days ago')-jira-data-backup.tar.gz
#OLDBACKFILE2=$BACKDIR$(date +%Y-%m-%d --date='20 days ago').zip
#
#if [ -f $OLDBACKFILE ]
#then
#        `rm -rf $OLDBACKFILE` >> $LOGFILE 2>&1
#    	echo " [$OLDBACKFILE] Delete Old Backup files Successful!" >> $LOGFILE
#else
#        echo "No Old backup files $OLDBACKFILE  !" >> $LOGFILE
#fi
#
#
#if [ -f $OLDBACKFILE2 ]
#then
#	`rm -rf $OLDBACKFILE2` >> $LOGFILE 2>&1
#    	echo " [$OLDBACKFILE2] Delete Old Backup files Successful!" >> $LOGFILE
#else
#        echo "No Old backup files $OLDBACKFILE2  !" >> $LOGFILE
#fi
#
#
## check the confluence old backup file
#OLDCBACKFILE=/var/atlassian/application-data/confluence/backups/backup-$(date +%Y_%m_%d --date='20 days ago').zip
#
#if [ -f $OLDCBACKFILE ]
#then
#        `rm -rf $OLDCBACKFILE` >> $LOGFILE 2>&1
#    	echo " [$OLDCBACKFILE] Delete Old Backup files Successful!" >> $LOGFILE
#else
#        echo "No Old backup files $OLDCBACKFILE  !" >> $LOGFILE
#fi
#
#echo "Jira Backup finished at  "$(date +"%Y-%m-%d %H:%M:%S") >> $LOGFILE
#
#cd $BACKDIR
