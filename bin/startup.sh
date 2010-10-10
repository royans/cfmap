#!/bin/bash


cd `dirname $0`
BASE0=`dirname $0`
BASE=${BASE0}/..
CONF=$BASE/conf/cfmap.properties
LOG=$BASE/logs

cfmap_port=`grep ^cfmap_port= $CONF | cut -d'=' -f2 `
cassandra_servers=`grep ^cassandra_servers= $CONF | cut -d'=' -f2 `

if [ "$cassandra_servers" == "localhost" ]
then
    cassandra_servers=`hostname`
fi

if [ "$cassandra_servers" == "" ]
then
    cassandra_servers=`hostname`
fi

cassandra_http_port=`grep ^cassandra_http_port= $CONF| cut -d'=' -f2 `
cassandra_jmx_port=`grep ^cassandra_jmx_port= $CONF| cut -d'=' -f2 `

if [ ! -d $LOG ]
then
	mkdir -p $LOG
fi

cp $BASE/conf/cassandra/* $BASE/cassandra/conf
perl -p -i -e "s#/usr/local/ingenuity/cfmap/cassandra#$BASE/cassandra_data#g" $BASE/cassandra/conf/*
perl -p -i -e "s#CFMAP_INSERT_SEED_HERE#<Seed>$cassandra_servers</Seed>#g" $BASE/cassandra/conf/*

if [ -d $BASE/cassandra_data ]
then
    cd $LOG
    chmod +x $BASE/cassandra/bin/cassandra
    nohup $BASE/cassandra/bin/cassandra -Dcom.sun.management.jmxremote.port=$cassandra_jmx_port start & > /dev/null 2> /dev/null 
    _PID1=$!
    nohup java -jar $BASE/lib/jetty-runner.jar --port $cfmap_port --out $BASE/logs/jetty.out --log $BASE/logs/jetty.log --path /cfmap $BASE/lib/cfmap.war & > /dev/null 2> /dev/null
    _PID2=$!

	# Like to keep the pid files separate so that I can control them individually.
    echo "$_PID1 $_PID2" > $LOG/running.pid  
	echo "$_PID1" > $LOG/cassandra.pid
	echo "$_PID2" > $LOG/cfmap.pid
fi

