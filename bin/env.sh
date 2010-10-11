#!/bin/bash

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin;export PATH;
OSTYPE=`uname`
CONF=$BASE/conf/cfmap.properties
LOG=$BASE/logs
PGREP=`which pgrep 2> /dev/null > /dev/null`
PKILL=`which pkill 2> /dev/null > /dev/null`
