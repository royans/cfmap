#!/bin/bash
cd /home/rkt/cc/cfmap/build
FILE=`ls -tra ../*tar.gz | grep gz | tail -1`
./upload.py -u royans -w $1 -p cfmap -s 'nightly build' ../$FILE
rm ../*.tar.gz



