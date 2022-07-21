#!/bin/bash


logdir='/home/admin/'

mysql_host='10.10.10.22'
mysql_user='root'
mysql_passwd='nb@233'
mysql_database='crowd'

#select cpu avg unitil
mysql -h $mysql_host -u $mysql_user -p$mysql_passwd $mysql_database >$logdir/user.txt<<EOF
set names utf8;
select u.user_name,u.email_address,a.attribute_name,a.attribute_value from cwd_user as u left join cwd_user_attribute a on u.id = a.user_id WHERE u.active = "T" and a.attribute_name = "passwordLastChanged";
EOF

