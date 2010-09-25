#!/bin/bash


cd `dirname $0`
BASE=`pwd`/..
CONF=$BASE/conf/cfmap.properties
LOG=$BASE/logs
source $CONF

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
    nohup $BASE/cassandra/bin/cassandra start & > /dev/null 2> /dev/null 
    nohup java -jar $BASE/lib/jetty-runner.jar --port $cfmap_port --path /cfmap $BASE/lib/cfmap.war & > /dev/null 2> /dev/null
fi

