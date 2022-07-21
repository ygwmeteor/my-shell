#!/bin/sh

# aim to sync Jira/Confluence install/home dir to dropbox
# crontab run every hour
# created by Gaowei Yuan at 2019-09-10


YEAR=`date +%Y`
MONTH=`date +%m`



LOGDIR="/var/atlassian/application-data/backup-log/Sync_dropbox"
LOGFILE=$LOGDIR-$YEAR-$MONTH-log


echo "=====================================================" >>$LOGFILE

echo $(date +'%Y-%m-%d %H:%M:%S')" Jira files sync begin" >> $LOGFILE

#rsync Jira files
rsync -av --delete --exclude-from '/var/atlassian/application-data/sync_exclude.txt' /var/atlassian/application-data/jira/ /home/backup/home_dir/jira/ >>$LOGFILE
echo "-----------------------------------------------------" >>$LOGFILE
rsync -av --exclude-from '/var/atlassian/application-data/sync_exclude.txt' /opt/atlassian/jira/ /home/backup/install_dir/jira/ >>$LOGFILE



echo "=====================================================" >>$LOGFILE

echo $(date +'%Y-%m-%d %H:%M:%S')" Confluence files sync begin" >> $LOGFILE
#rsync Confluence files
rsync -av --delete --exclude-from '/var/atlassian/application-data/sync_exclude.txt' /var/atlassian/application-data/confluence/ /home/backup/home_dir/confluence/ >>$LOGFILE

echo "-----------------------------------------------------" >>$LOGFILE
rsync -av --exclude-from '/var/atlassian/application-data/sync_exclude.txt' /opt/atlassian/confluence/ /home/backup/install_dir/confluence/ >>$LOGFILE


echo "=====================================================" >>$LOGFILE

echo $(date +'%Y-%m-%d %H:%M:%S')" Crowd files sync begin" >> $LOGFILE
#rsync Crowd files
rsync -av --delete --exclude-from '/var/atlassian/application-data/sync_exclude.txt' /var/atlassian/application-data/crowd-home/ /home/backup/home_dir/crowd-home/ >>$LOGFILE

echo "-----------------------------------------------------" >>$LOGFILE
rsync -av --exclude-from '/var/atlassian/application-data/sync_exclude.txt' /opt/atlassian/crowd/ /home/backup/install_dir/crowd/ >>$LOGFILE
