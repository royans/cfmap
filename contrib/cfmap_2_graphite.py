#!/usr/bin/python
"""Copyright 2008 Orbitz WorldWide

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License."""

"""
Significantly modified by  Royans K Tharakan to import data from cfmap <rkt@pobox.com>

Instructions: run this on the graphite server and update the cfmap url to the location from where feed should be pulled from

"""

import sys
import time
import os
import platform
import subprocess
import urllib
from socket import socket

CARBON_SERVER = '127.0.0.1'
CARBON_PORT = 2003
#CARBON_PORT = 9200

delay = 60
if len(sys.argv) > 1:
  delay = int( sys.argv[1] )
host2clustername={}
host2zonename={}

def load_clusterhost_map():
  md5host={}
  if platform.system() == "Linux":
    dump=urllib.urlopen("http://webtrace.info/cfmap/browse/view.jsp?z=dev&f=s&cols=host,clustername")
    #dump=urllib.urlopen("http://cfmap.ingenuity.com:8083/cfmap/browse/view.jsp?z=dev&f=s&cols=host,clustername")
    dumplines=dump.readlines()
    dumplines.sort();
    for dumpline in dumplines:
        _a=dumpline.strip().split(":")
        if (len(_a)>1):
            _b=_a[1].split("=")
            if (_b[0]=="host"):
                md5host[_a[0]]=_b[1]
    for dumpline in dumplines:
        _a=dumpline.strip().split(":")
        if (len(_a)>1):
            _b=_a[1].split("=")
            if (_b[0]=="zonename"):
                host2zonename[ md5host[_a[0]] ]=_b[1]
            if (_b[0]=="clustername"):
                host2clustername[ md5host[_a[0]] ]=_b[1]

def get_stats():
  if platform.system() == "Linux":
    return urllib.urlopen("http://webtrace.info/cfmap/browse/viewrecordhistory.jsp?key=updatefeed&z=dev&f=stats")

load_clusterhost_map()
sock = socket()
try:
  sock.connect( (CARBON_SERVER,CARBON_PORT) )
except:
  print "Couldn't connect to localhost on port %d, is carbon-agent.py running?" % CARBON_PORT
  sys.exit(1)

if True:
    lines = []
    hash={};
    stats = get_stats()
    output=stats.readlines()
    output.sort()
    output.reverse()
    for item in output:
        rowsplit=item.strip().split(':')
        if len(rowsplit)>1:
            props=rowsplit[1].split(',')
            logtime=int(rowsplit[0])/1000
            l=str(logtime)
            l_1=str(logtime+60)
            l_2=str(logtime+120)
            l_3=str(logtime+180)
            l_4=str(logtime+240)
            l_5=str(logtime+300)
            if len(props)>1:
                for prop in props:
                    keyval= prop.strip().split('=')
                    if ((len(keyval)>1) and (len(keyval[1])>0)):
                        recordkey=""
                        recordkey_parts=keyval[0].split(".")
                        if recordkey_parts[0] == "server":
                            if recordkey_parts[1] in host2zonename and recordkey_parts[1] in host2clustername:
                                recordkey="server."+host2zonename[recordkey_parts[1]]+"."+host2clustername[recordkey_parts[1]].replace(".","-")+"."+recordkey_parts[1]+"."+recordkey_parts[2]
			    else:
				recordkey="system."+recordkey_parts[1]+"."+recordkey_parts[2]
                        else:
                            recordkey=keyval[0]
                        if len(recordkey)>1:
                            lines.append(recordkey+" "+keyval[1]+" "+l)
                            if (keyval[0] not in hash ):
                                hash[keyval[0]]=1
                                lines.append(recordkey+" "+keyval[1]+" "+l_1)
                                lines.append(recordkey+" "+keyval[1]+" "+l_2)
                                lines.append(recordkey+" "+keyval[1]+" "+l_3)
                                lines.append(recordkey+" "+keyval[1]+" "+l_4)
                                lines.append(recordkey+" "+keyval[1]+" "+l_5)
                            print recordkey+" "+keyval[1]+" "+l
    message = '\n'.join(lines) + '\n' #all lines must end in a newline
    sock.sendall(message)
   #time.sleep(delay)


