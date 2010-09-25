#!/bin/bash


cd `dirname $0`
BASE=`pwd`/..
LOG=$BASE/logs

if [ -d $BASE/cassandra_data ]
then
    user=`whoami`

    PIDS=`cat $LOG/running.pid`
    for pid in `echo $PIDS`
    do
	kill -9 $pid > /dev/null 2> /dev/null
    done
    pgrep -u $user -f cassandra | xargs kill -9 2> /dev/null > /dev/null
fi

