#!/bin/bash


cd `dirname $0`
BASE=`pwd`/..
CONF=$BASE/conf/cfmap.properties
source $CONF

cp $BASE/conf/cassandra/* $BASE/cassandra/conf
perl -p -i -e "s#/usr/local/ingenuity/cfmap/cassandra#$BASE/cassandra_data#g" $BASE/cassandra/conf/*
perl -p -i -e "s#CFMAP_INSERT_SEED_HERE#<Seed>$cassandra_servers</Seed>#g" $BASE/cassandra/conf/*

cd $BASE/cassandra/bin
perl -p -i -e "s#com.sun.management.jmxremote.port=$cassandra_http_port#com.sun.management.jmxremote.port=$cassandra_jmx_port#g" $BASE/cassandra/bin/*
mkdir -p $BASE/cassandra_data

if [ -d $BASE/cassandra_data ]
then
    $BASE/cassandra/bin/cassandra start 2> /dev/null 
fi

