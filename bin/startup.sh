#!/bin/bash


cd `dirname $0`
BASE=`pwd`/..
CONF=$BASE/conf/cfmap.properties
LOG=$BASE/logs
#source $CONF > /dev/null 2> /dev/null

cfmap_port=`cat $CONF | grep ^cfmap_port= | cut -d'=' -f2 | sed -e's/\r//g' | sed -e's/\n//g'`
cassandra_servers=`cat $CONF | grep ^cassandra_servers= | cut -d'=' -f2  | sed -e's/\r//g' | sed -e's/\n//g'`
cassandra_http_port=`cat $CONF | grep ^cassandra_http_port= | cut -d'=' -f2  | sed -e's/\r//g' | sed -e's/\n//g'`
cassandra_jmx_port=`cat $CONF | grep ^cassandra_jmx_port= | cut -d'=' -f2  | sed -e's/\r//g' | sed -e's/\n//g'`

mkdir -p $LOG

cp $BASE/conf/cassandra/* $BASE/cassandra/conf
perl -p -i -e "s#/usr/local/ingenuity/cfmap/cassandra#$BASE/cassandra_data#g" $BASE/cassandra/conf/*
perl -p -i -e "s#CFMAP_INSERT_SEED_HERE#<Seed>$cassandra_servers</Seed>#g" $BASE/cassandra/conf/*

cd $BASE/cassandra/bin
perl -p -i -e "s#com.sun.management.jmxremote.port=$cassandra_http_port#com.sun.management.jmxremote.port=$cassandra_jmx_port#g" $BASE/cassandra/bin/*.sh
mkdir -p $BASE/cassandra_data

if [ -d $BASE/cassandra_data ]
then
    cd $LOG
    chmod +x $BASE/cassandra/bin/cassandra
    nohup $BASE/cassandra/bin/cassandra start & > /dev/null 2> /dev/null 
    _PID1=$!
    nohup java -jar $BASE/lib/jetty-runner.jar --port $cfmap_port --out $BASE/logs/jetty.out --log $BASE/logs/jetty.log --path /cfmap $BASE/lib/cfmap.war  > /dev/null 2> /dev/null
    _PID2=$!

    echo "$_PID1 $_PID2" > $LOG/running.pid
fi

