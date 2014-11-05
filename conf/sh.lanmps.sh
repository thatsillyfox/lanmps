#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# Check if user is root
if [ $UID != 0 ]; then
    echo "Error: You must be root to run this script!"
    exit 1
fi

IN_DIR="/www/lanmps"
echo "========================================================================="
echo "Manager for LANMPS V0.1 "
echo "========================================================================="
echo "LANMPS is a tool to auto-compile & install Apache+Nginx+MySQL+PHP on Linux "
echo "This script is a tool to Manage status of lanmps "
echo "For more information please visit http://www.lanmps.com "
echo ""
echo "   Usage: /root/lanmps {start|stop|reload|restart|kill|status}"
echo "or Usage: $IN_DIR/lanmps {start|stop|reload|restart|kill|status}"
echo "========================================================================="

function_start()
{
    echo "Starting LNMP..."
	
    /etc/init.d/nginx start

    /etc/init.d/php-fpm start

    /etc/init.d/mysql start
}

function_stop()
{
    echo "Stoping LNMP..."
	
    /etc/init.d/nginx stop

    /etc/init.d/php-fpm stop

    /etc/init.d/mysql stop
}

function_reload()
{
    echo "Reload LNMP..."
	
    /etc/init.d/nginx reload

    /etc/init.d/php-fpm reload

    /etc/init.d/mysql reload
}

function_kill()
{
    killall nginx
    killall php-cgi
    killall php-fpm
    killall mysqld
}

function_status()
{
    /etc/init.d/nginx status

    /etc/init.d/php-fpm status

	/etc/init.d/mysql status
}

case "$1" in
	start)
		function_start
		;;
	stop)
		function_stop
		;;
	restart)
		function_stop
		function_start
		;;
	reload)
		function_reload
		;;
	kill)
		function_kill
		;;
	status)
		function_status
		;;
	*)
esac
echo "Usage: $IN_DIR/lanmps {start|stop|reload|restart|kill|status}"
echo "or Usage: $IN_DIR/lanmps {start|stop|reload|restart|kill|status}"
exit