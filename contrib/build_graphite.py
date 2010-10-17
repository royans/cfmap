#!/bin/bash

# Royans K Tharakan <rkt@pobox.com> 2010
# requires gcc, pkgconfig, cairo, pycairo, libpng, libpng-devel,
# For more detailed info, look at the end of this script

BASE=/usr/local/ingenuity/allstat
DOWNLOAD=$BASE/download
COMPILE=$BASE/compile
PREFIX=$BASE
PATH=$PREFIX:$PREFIX/bin:$PATH
export PATH

function check_tools
{
    for  tool in gcc grep make
    do
	which $tool
	if [ $? -eq 1 ]
	then
		echo "$tool not found"
		exit 1
	fi
    done

}

function init
{
    rm -rf $COMPILE
    mkdir -p $COMPILE
    mkdir -p $DOWNLOAD
    if [ -d $DOWNLOAD ]
    then
	echo "initiating build"
    else
	echo "Problem creating $DOWNLOAD"
    fi
}

function get_download
{
    url=$1
    name=$2
    tarname=$3

    cd $DOWNLOAD
    if [ -f $tarname ]
    then
        echo "$tarname found"
    else
	echo "$tarname not found : downloading"
        wget $url > /dev/null  2> /dev/null
        mv $name* $tarname
    fi

    if [ -d $COMPILE/$name ]
    then
	echo "$COMPILE/$name exists"
    else
    cd $COMPILE
    if [[ $tarname == *gz* ]]
    then
    	tar -xzf $DOWNLOAD/$tarname 
    else
	if [ -f $DOWNLOAD/$name.tar.bz2 ]
	then
		echo "$DOWNLOAD/$name.tar.bz2 exists"
	else
		cp $DOWNLOAD/$tarname $DOWNLOAD/$name.tar.bz2
	fi
        cp $DOWNLOAD/$name.tar.bz2 $DOWNLOAD/$name.1.tar.bz2
	bzip2 -d $DOWNLOAD/$name.1.tar.bz2
        tar xf $DOWNLOAD/$name.1.tar
	rm $DOWNLOAD/$name.1.tar
    fi
    mv $COMPILE/$name* $COMPILE/$name 2> /dev/null
       if [ $name == "py2cairo" ]
       then
	   mv $COMPILE/pycairo* $COMPILE/py2cairo
       fi
    fi
}

function check_download
{
    get_download http://cairographics.org/releases/py2cairo-1.8.10.tar.gz py2cairo py2cairo.tar.gz
    get_download http://tmrc.mit.edu/mirror/twisted/Twisted/10.1/Twisted-10.1.0.tar.bz2 Twisted Twisted.tar.bz2
    get_download http://cairographics.org/releases/cairo-1.10.0.tar.gz cairo cairo.tar.gz
    get_download http://graphite.wikidot.com/local--files/downloads/carbon-0.9.6.tar.gz carbon carbon.tar.gz
    get_download http://graphite.wikidot.com/local--files/downloads/graphite-web-0.9.6.tar.gz graphite-web graphite-web.tar.gz
    get_download http://graphite.wikidot.com/local--files/downloads/whisper-0.9.6.tar.gz whisper whisper.tar.gz
    get_download http://python.org/ftp/python/2.6.6/Python-2.6.6.tgz Python Python.tgz
    get_download http://cairographics.org/releases/pixman-0.19.4.tar.gz pixman pixman.tar.gz
    get_download http://www.zope.org/Products/ZopeInterface/3.3.0/zope.interface-3.3.0.tar.gz zope.interface zope.interface.tar.gz
    get_download http://www.djangoproject.com/download/1.2.3/tarball/ Django Django.tar.gz }

function compile_python
{
    if [ -f $BASE/bin/python ]
    then
 	echo "python installed"
    else
    	cd $COMPILE/Python
    	./configure --prefix=$PREFIX ; make; make install
    fi
}

function compile_pixman
{
    cd $COMPILE/pixman;
    ./configure --prefix=$PREFIX ; make; 
    cp $COMPILE/pixman/pixman-1.pc /usr/lib/pkgconfig
    echo "==============================================================================="
    echo "==============================================================================="
    echo "==============================================================================="
    echo "==============================================================================="
    echo "==============================================================================="
    echo "Run as ROOT : cp $COMPILE/pixman/pixman-1.pc /usr/lib/pkgconfig "
    echo "==============================================================================="
    echo "==============================================================================="
    echo "==============================================================================="
    echo "==============================================================================="
    echo "==============================================================================="
    cp $COMPILE/pixman/pixman/.libs/* $PREFIX/lib
    cp $COMPILE/pixman/pixman/*.h $COMPILE/cairo/src }

function compile_Django
{
    if [ -d $PREFIX/lib/python2.6/site-packages/django/ ]
    then
  	echo "Django already installed"
    else
    	cd $COMPILE/Django;
    	python setup.py install
    fi
}

function compile_cairo
{
    cd $COMPILE/cairo;
    PKG_CONFIG_PATH=../pixman/
    export PKG_CONFIG_PATH
    ./configure --prefix=$PREFIX ; make; make install }

function compile_carbon
{
    if [ -d $PREFIX/carbon/conf ]
    then
	echo "Carbon installed"
    else
    cd $COMPILE/carbon; 
    cat setup.cfg | grep -v ^prefix > setup.cfg.1
    echo "prefix = $PREFIX/carbon" >> setup.cfg.1
    mv setup.cfg.1 setup.cfg
    #./configure --prefix=$PREFIX ; make; make install
    python setup.py install
    cd $PREFIX/carbon/conf
    for f in `ls *.conf.example`
    do
	n=`echo $f | sed -e's/.example//g'`
	cp $f $n
    done

    perl -i -pe "s#/opt/graphite/storage/whisper/#$PREFIX/graphite/storage/whisper/#g" carbon.conf
    perl -i -pe 's/= 2003/= 9200/g' *.conf  
    perl -i -pe 's/= 2004/= 9201/g' *.conf
    perl -i -pe 's/= 7002/= 9202/g' *.conf

cat << EOF > $BASE/carbon/conf/storage-schemas.conf
[everything_1min_1day]
priority = 100
pattern = system.*
retentions = 60:43200,300:1051200,900:3504000

[everything_1min_1day]
priority = 100
pattern = server.*
retentions = 60:43200,300:1051200,900:3504000

[everything_1min_1day]
priority = 100
pattern = process.*
retentions = 60:43200,300:1051200,900:3504000 EOF

    #echo "LOCAL_DATA_DIR = $PREFIX/graphite/storage/whisper/" > carbon.conf.new
    #cat carbon.conf | grep -v ^LOCAL_DATA_DIR >> carbon.conf.new
    #mv carbon.conf.new carbon.conf
    fi
}

function compile_graphite
{ 
    if [ -d $PREFIX/graphite/bin ]
    then
	echo "Graphite already installed"
    else
    	cd $COMPILE/graphite-web; 
    	cat setup.cfg | grep -v ^prefix > setup.cfg.1
    	echo "prefix = $PREFIX/graphite" >> setup.cfg.1
    	mv setup.cfg.1 setup.cfg
    	python setup.py install

    	perl -i -pe 's/= 8080/= 9203/g' $PREFIX/graphite/bin/*.py

	PATH=$PREFIX/bin:$PATH
	export PATH
    	cd $PREFIX/graphite/webapp/graphite
    	python manage.py syncdb
    fi
}

function compile_Twisted
{
    if [ -f $PREFIX/bin/twistd ]
    then
	echo "Twisted installed"
    else
    	cd $COMPILE/Twisted
    	python setup.py install
    fi
}

function compile_py2cairo
{
  PATH=/usr/local/ingenuity/allstat/bin:$PATH
  export PATH
  cd $COMPILE/py2cairo
  PKG_CONFIG_PATH=../cairo/:../pixman/
  export PKG_CONFIG_PATH
  ./configure --prefix=$PREFIX
  make
  make install
}

function compile_whisper
{
    if [ -f $PREFIX/bin/rrd2whisper.py ]
    then
	echo "Whisper installed"
    else
    	cd $COMPILE/whisper;
       	python setup.py install
    fi
}


function compile_zope
{
    if [ -d $PREFIX/lib/python2.6/site-packages/zope/interface ]
    then
	echo "zope installed"
    else
    	cd $COMPILE/zope.interface;
    	python setup.py install
    fi
}

function setup_script
{
PORT=9203
cat << EOF > $PREFIX/startup.sh
#!/bin/bash
PREFIX=$PREFIX
PORT=$PORT
PATH=$PREFIX/bin:$PATH

cd $PREFIX/carbon
./bin/carbon-cache.py start
if [ $? -eq 1 ]
then
        echo "Carbon startup failed... please investigate"
fi

cd $PREFIX/graphite/bin
nohup ./run-graphite-devel-server.py --port $PORT $PREFIX/graphite 2> /dev/null > /dev/null & if [ $? -eq 1  ] then
        echo "Graphite startup failed... please investigate"
fi
EOF
chmod +x  $PREFIX/startup.sh

}

function build
{
    init
    check_tools
    check_download
    compile_python
    compile_Django
    compile_Twisted
    compile_pixman
    compile_cairo
    compile_py2cairo
    compile_zope
    compile_carbon
    compile_whisper
    compile_graphite
    setup_script
    #post_install
}

build



exit

=====
# The following components might be required to make this script work.
# There has been an attempt made to allow graphite to run without any root access once compiled and deployed.
# It also makes an attempt to build and deploy everything it needs it its own directory which could make coexisting with other applications easy
======
zypper install make
zypper install sqlite3-devel
zypper install apache2-mod_python
zypper install automake
zypper install cairo
zypper install cairo-devel
zypper install free-ttf-fonts
zypper install freefont
zypper install gcc
zypper install git
zypper install libmemcache
zypper install libpixman-1-0
zypper install libpixman-1-0-devel
zypper install librsvg
zypper install maven
zypper install memcache
zypper install memcached
zypper install mod_python
zypper install mysql
zypper install pixman
zypper install pkg-config
zypper install pycairo
zypper install python
zypper install python-cairo
zypper install python-ldap
zypper install python-memcache
zypper install python-memcached
zypper install python-sqlite2
zypper install python-twisted
zypper install python2.6
zypper install python_module
zypper install xorg-x11-fonts
zypper install yum



