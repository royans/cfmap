#!/bin/bash
cd `dirname $0`
BASE=`pwd`

########################################
# check for tools
########################################

TOOLS="ant java javac"
for TOOL in `echo $TOOLS`
do
    T=`which $TOOL`
    if [ $? -gt 0 ]
    then
        echo "$TOOL not found"
    else
        echo "$TOOL found :$T"
    fi
done


########################################
# prepare dirs
########################################

mkdir -p $BASE/output
mkdir -p $BASE/tmp
cd $BASE/tmp

########################################
# compile cfmap
########################################

cd $BASE/build
ant


########################################
# prepare jetty
########################################

JETTYC=jetty-contrib-7.0.0.pre5
cd $BASE/tmp
svn co https://svn.codehaus.org/jetty-contrib/jetty/tags/$JETTYC/
cd $JETTYC/jetty-runner
mvn clean install
cp $BASE/tmp/$JETTYC/jetty-runner/target/jetty-runner*.jar $BASE/output/jetty-runner.jar
cd $BASE

########################################
# prepare cassandra
########################################

tar -xvzf contrib/apache-cassandra-0.6.4-bin.tar.gz
rm -rf cassandra-live
mv apache-cassandra-0.6.4 cassandra-live
cp contrib/cassandra/* cassandra-live/conf/

# update config to point to local cassandra_data dir
cd cassandra-live/conf
perl -p -i -e "s#/usr/local/ingenuity/cfmap/cassandra#$BASE/cassandra_data#g" *
perl -p -i -e "s#CFMAP_INSERT_SEED_HERE#<Seed>127.0.0.1</Seed>#g" *

cd $BASE/cassandra-live/bin
perl -p -i -e "s#com.sun.management.jmxremote.port=8080#com.sun.management.jmxremote.port=8081#g" *
cd $BASE
mkdir -p $BASE/cassandra_data



exit

######################################################################################################################
######################################################################################################################
######################################################################################################################
######################################################################################################################
######################################################################################################################


cp $BASE/output/cfmap.war tomcat-live/webapps/
mv $BASE/output $BASE/build

pid8005=`lsof -ai | grep ":8005" | awk '{print $2}'`; kill -9 $pid8005 2> /dev/null
pid8080=`lsof -ai | grep ":8080" | awk '{print $2}'`; kill -9 $pid8080 2> /dev/null
pid8081=`lsof -ai | grep ":8081" | awk '{print $2}'`; kill -9 $pid8081 2> /dev/null
user=`whoami`
pgrep -u $user -f cassandra | xargs kill -9 2> /dev/null
pgrep -u $user -f java | xargs kill -9 2> /dev/null

