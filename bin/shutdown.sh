#!/bin/bash


BASE0=`dirname $0`
BASE=${BASE0}/..
LOG=$BASE/logs

if [ -d $BASE/cassandra_data ]
then
    user=`whoami`
    CFMAP_PID=`cat $LOG/cfmap.pid`
	kill -9 $CFMAP_PID > /dev/null 2> /dev/null
	CASSANDRA_PID=`cat $LOG/cassandra.pid`
	kill -9 $CASSANDRA_PID > /dev/null 2> /dev/null
	
	# need to start cassandra in the foreground
    #pgrep -u $user -f cassandra | xargs kill -9 2> /dev/null > /dev/null
fi

