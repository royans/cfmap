#!/bin/bash
cd `dirname $0`
BASE=`pwd`/..

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
cp $BASE/tmp/$JETTYC/jetty-runner/target/jetty-runner*.jar $BASE/output/lib/jetty-runner.jar
cd $BASE

########################################
# prepare cassandra
########################################

tar -xvzf contrib/apache-cassandra-0.6.4-bin.tar.gz
rm -rf cassandra
mv apache-cassandra-0.6.4 $BASE/output/cassandra

rm -rf $BASE/output/target
