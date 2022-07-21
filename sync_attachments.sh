#!/bin/sh

# aim to sync Jira/Confluence attachments files to backup server 10.10.10.12
# crontab run every hour
# created by Gaowei Yuan at 2016-06-13


YEAR=`date +%Y`
MONTH=`date +%m`



LOGDIR="/var/atlassian/application-data/backup-log/Sync"
LOGFILE=$LOGDIR-$YEAR-$MONTH-log


echo "=====================================================" >>$LOGFILE

echo $(date +'%Y-%m-%d %H:%M:%S')" Attachment files sync begin" >> $LOGFILE

#rsync Jira data
rsync -avz --delete -e ssh /var/atlassian/application-data/jira/data/ root@10.10.10.22:/var/atlassian/application-data/jira/data/ >>$LOGFILE

echo "-----------------------------------------------------" >>$LOGFILE

rsync -avz --delete -e ssh /var/atlassian/application-data/jira/data/ root@192.168.29.186:/var/atlassian/application-data/jira/data/ >>$LOGFILE

echo "*****************************************************" >>$LOGFILE

#rsync Confluence attachments
rsync -avz --delete -e ssh /var/atlassian/application-data/confluence/attachments/ root@10.10.10.22:/var/atlassian/application-data/confluence/attachments >>$LOGFILE

echo "-----------------------------------------------------" >>$LOGFILE

rsync -avz --delete -e ssh /var/atlassian/application-data/confluence/attachments/ root@192.168.29.186:/var/atlassian/application-data/confluence/attachments >>$LOGFILE

echo $(date +'%Y-%m-%d %H:%M:%S')" Attachment files sync finished" >> $LOGFILE
