AC_INIT(myconfig, version-0.1)
AC_MSG_NOTICE([Hello, world.])
AC_PROG_CC
AC_SUBST(appname, cfmap)
AC_PATH_PROG(MAVEN,mvn)
echo $MAVEN
if test "x$MAVEN" = "x"; then
	  AC_MSG_ERROR(you need to have maven installed!)
fi
AC_PATH_PROG(ANT,ant)
if test "x$ANT" = "x"; then
	  AC_MSG_ERROR(you need to have ant installed!)
fi
AC_PATH_PROG(JAVA,java)
if test "x$JAVA" = "x"; then
	  AC_MSG_ERROR(you need to have java installed!)
fi
AC_PATH_PROG(JAVAC,javac)
if test "x$JAVAC" = "x"; then
	  AC_MSG_ERROR(you need to have javac installed!)
fi
AC_CONFIG_FILES([additionalbuild.sh], [chmod +x additionalbuild.sh])
AC_OUTPUT(build.xml bin/startup.sh bin/shutdown.sh contrib/cassandra/log4j.properties contrib/cassandra/storage-conf.xml)

