#!/bin/sh

# 环境变量
export LUASTAR_PATH="/Users/zhuminghua/Documents/code-zmh/luastar"
export LUASTAR_CONFIG_FILE="/admin-backend/config/app_dev.lua"

# 脚本变量
PROGNAME=/Users/zhuminghua/Documents/apps/openresty-1.27.1.1/bin/openresty
RUNPATH="${LUASTAR_PATH}/admin-backend/scripts"
DESC="Openresty"

# 替换变量，生成配置文件
envsubst '${LUASTAR_PATH}' < ${RUNPATH}/nginx.conf.template > ${RUNPATH}/nginx.conf

version()
{
	if test -x ${PROGNAME}
	then
		${PROGNAME} -v
  fi
}

start()
{
	if test -x ${PROGNAME}
	then
		echo -e "Starting ${DESC}:"
		if ${PROGNAME} -c ${RUNPATH}/nginx.conf -p ${RUNPATH}
		then
    		echo -e "ok."
    else
			echo -e "failed."
		fi
	else
		echo -e "Couldn't find ${PROGNAME}."
  fi
}

stop()
{
	if test -e ${RUNPATH}/logs/nginx.pid
	then
		echo -e "Stopping ${DESC}:"
    	if kill `cat ${RUNPATH}/logs/nginx.pid`
		then
			echo -e "ok."
		else
			echo -e "failed."
		fi
	else
		echo -e "no ${DESC} running."
  fi
}

restart()
{
	echo -e "Restarting ${DESC}:"
	if ${PROGNAME} -c ${RUNPATH}/nginx.conf -p ${RUNPATH} -s reload
	then
		echo -e "ok."
	else
		stop
		start
	fi
}

list()
{
	ps aux | grep ${PROGNAME}
}

case $1 in
	version)
		version
		;;
	start)
		start
    	;;
	stop)
		stop
    	;;
	restart)
  		restart
    	;;
	list)
  		list
    	;;
	*)
  		echo "Usage: sh run.sh {version|start|stop|restart|list}" >&2
    	exit 1
   	 	;;
esac
exit 0
