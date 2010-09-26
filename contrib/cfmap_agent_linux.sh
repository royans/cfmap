#!/bin/bash
HOST=`hostname`
CFMAPURL='http://webtrace.info'
FREEMEM=`free -m  | grep Mem: | awk '{print $4}'`
TOTALMEM=`free -m  | grep Mem: | awk '{print $2}'`
LOADAVG1M=`cat /proc/loadavg | cut -d' ' -f1`
UPTIME=`cat /proc/uptime| cut -d' ' -f1`
IDLETIME=`cat /proc/uptime| cut -d' ' -f2`
ESTCONN=`netstat -na | grep EST | wc -l`
STATUS="running"
PSCOUNT=`ps -e | wc -l`
LOCATION="unknown"
CLUSTER="primary"
APPNAME="apache"
PORT="80"

lynx --source "$CFMAPURL/cfmap/browse/create.jsp?z=dev&c=update&host=$HOST&service=www&pk=test&group=$CLUSTER&stats_host_freemem=$FREEMEM&stats_host_totalmem=$TOTALMEM&stats_host_loadavg1m=$LOADAVG1M&stats_host_uptime=$UPTIME&stats_host_idletime=$IDLETIME&stats_host_estconn=$ESTCONN&stats_host_pscount=$PSCOUNT&location=$LOCATION&appname=$APPNAME&port=$PORT&status=running" 2> /dev/null

