#!/bin/bash

# auto tar confluence access logs and rm the old logs
# created at 2020.09.24 by Gavin


log_path="/var/atlassian/application-data/confluence/logs/"
files=`ls /var/atlassian/application-data/confluence/logs |grep access.log. |grep -v tar.gz`


for i in $files;do
     # get the file modify date
    d=`stat $log_path$i | sed -n 7p | awk '{print $2}'`
    tar -zcvf $log_path$i-$d.tar.gz $log_path$i >/dev/null 2>&1 && rm -rf $log_path$i
done
