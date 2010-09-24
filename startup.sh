#!/bin/bash


cd `dirname $0`
BASE=`pwd`

if [ -d $BASE/cassandra_data ]
then
    $BASE/tomcat-live/bin/startup.sh  2> /dev/null
    $BASE/cassandra-live/bin/cassandra start 2> /dev/null 
fi

