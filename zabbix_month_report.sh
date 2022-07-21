#!/bin/bash
. /etc/profile
logdir='/home/admin/zabbix/zabbix_log'
mysql_host='localhost'
mysql_user='root'
mysql_passwd='nb@233'
mysql_database='zabbix'
year=`date +%Y`
month=`date +%m`
next_month=`echo $month+1|bc`

#if today is the last day of month
#then run this script
##################################################
today=`date +%d`
last_day=`cal | xargs | awk '{print $NF}'`
if [ "$today" != "$last_day" ]; then 
exit 1
fi
#################################################




if [ ! -d $logdir ];then
    mkdir $logdir
fi

##zabbix host month report
#select cpu avg unitil
mysql -h $mysql_host -u $mysql_user -p$mysql_passwd $mysql_database >$logdir/cpu$month.txt<<EOF
set names utf8;
select from_unixtime(hi.clock,'%m') as Date,g.name as Group_Name,h.host as Host, round(avg(hi.value_avg),1) as Cpu_Avg_Unitil,round(max(hi.value_max),1) as Cpu_Max_Unitil  from hosts_groups hg join groups g on g.groupid = hg.groupid join items i on hg.hostid = i.hostid join hosts h on h.hostid=i.hostid join trends hi on  i.itemid = hi.itemid  where  i.name='CPU unitil' and  hi.clock >= UNIX_TIMESTAMP('${year}-${month}-01 00:00:00') and  hi.clock < UNIX_TIMESTAMP('${year}-0${next_month}-01 00:00:00') group by h.host;
EOF
#select Mem usage
mysql -h $mysql_host  -u $mysql_user -p$mysql_passwd $mysql_database >$logdir/mem$month.txt<<EOF
set names utf8;
select from_unixtime(hi.clock,'%m') as Date,g.name as Group_Name,h.host as Host, round(avg(hi.value_avg),1) as Mem_Avg_usage,round(max(hi.value_max),1) as Mem_Max_Usage   from hosts_groups hg join groups g on g.groupid = hg.groupid join items i on hg.hostid = i.hostid join hosts h on h.hostid=i.hostid join trends hi on  i.itemid = hi.itemid  where  i.name='Mem usage' and  hi.clock >= UNIX_TIMESTAMP('${year}-${month}-01 00:00:00') and  hi.clock < UNIX_TIMESTAMP('${year}-0${next_month}-01 00:00:00') group by h.host;
EOF

sed -i '1d' $logdir/cpu$month.txt
sed -i '1d' $logdir/mem$month.txt
awk 'NR==FNR{a[$1,$2,$3,$4]=$0;next}{print a[$1,$2,$3,$4],"\t",$5,"\t",$6}' $logdir/cpu$month.txt $logdir/mem$month.txt >$logdir/result$month.txt
sed -i '1i Month\tGroup name\tHost\tCpu_avg_Unitil\tCpu_Max_Unitil\tMem_Avg_usage\tMem_Max_Usage' $logdir/result$month.txt

rm -rf $logdir/cpu$month.txt
rm -rf $logdir/mem$month.txt
