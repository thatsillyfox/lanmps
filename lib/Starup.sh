# start services
function Starup()
{
	echo "Create PHP Info Tool..."
	#TOOLS
	cd $IN_PWD
	cp conf/index.html $IN_WEB_DIR/default/index.html
	cp conf/php.tz.php $IN_WEB_DIR/default/_tz.php
	cat > $IN_WEB_DIR/default/_phpinfo.php<<EOF
<?php
phpinfo();
?>
EOF
	
	echo "============================add nginx and php-fpm on startup============================"
	echo "Set start"
	if [ $OS_RL = "centos" ]; then
		chkconfig --level 345 php-fpm on
		chkconfig --level 345 nginx on
		chkconfig --level 345 mysql on
		chkconfig --level 345 memcached on
	else
		update-rc.d -f php-fpm defaults
		update-rc.d -f nginx defaults
		update-rc.d -f mysql defaults
		update-rc.d -f memcached defaults
	fi
	
	echo "===========================add nginx and php-fpm on startup completed===================="
	
	file_cp $IN_PWD/conf/sh.lanmps.sh "${IN_DIR}/lanmps"
	if [ ! $IN_DIR = "/www/lanmps" ]; then
		sed -i 's:/www/lanmps:'$IN_DIR':g' $IN_DIR/lanmps
	fi
	chmod +x "${IN_DIR}/lanmps"
	ln -s $IN_DIR/lanmps /root/lanmps
	#sed -i "s:/usr/local/php/logs:$IN_DIR/php/var/run:g" "${IN_DIR}/lnmp"
	
	echo "Starting LNMP..."
	$IN_DIR/init.d/$MYSQL_INITD start
	
	$IN_DIR/init.d/php-fpm start
	$IN_DIR/init.d/nginx start
	$IN_DIR/init.d/memcached start
	
	#add 80 port to iptables
	if [ -s /sbin/iptables ]; then
		/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
		/sbin/iptables -I INPUT -p tcp --dport 21 -j ACCEPT
		/sbin/iptables -I INPUT -p tcp --dport 22 -j ACCEPT
		iptables-save > /etc/iptables.up.rules
		iptables-save > /etc/network/iptables.up.rules
		#/etc/rc.d/init.d/iptables save
		#/etc/init.d/iptables restart
	fi
}

function CheckInstall()
{
	echo "===================================== Check install ==================================="
	clear
	isnginx=""
	ismysql=""
	isphp=""
	echo "Checking..."
	if [ -s $IN_DIR/nginx ] && [ -s $IN_DIR/nginx/sbin/nginx ]; then
	  echo "Nginx: OK"
	  isnginx="ok"
	else
	  echo "Error: $IN_DIR/nginx not found!!!Nginx install failed."
	fi

	if [ -s "$IN_DIR/php/sbin/php-fpm" ] && [ -s "$IN_DIR/php/php.ini" ] && [ -s $IN_DIR/php/bin/php ]; then
		echo "PHP: OK"
		echo "PHP-FPM: OK"
		isphp="ok"
	else
		echo "Error: $IN_DIR/php not found!!!PHP install failed."
	fi

	if [ -s "$IN_DIR/$MYSQL_INITD" ] && [ -s "$IN_DIR/mysql/bin/mysql" ]; then
		  echo "MySQL: OK"
		  ismysql="ok"
		else
		  echo "Error: $IN_DIR/${MYSQL_INITD} not found!!!MySQL install failed."
		fi
	
	if [ "$isnginx" = "ok" ] && [ "$ismysql" = "ok" ] && [ "$isphp" = "ok" ]; then
		echo "========================================================================="
		echo "LANMPS V0.1 for CentOS/Ubuntu Linux Written by Licess "
		echo "========================================================================="
		echo ""
		echo "For more information please visit http://www.lanmps.com"
		echo ""
		echo "lanmps status manage: $IN_DIR/lanmps {start|stop|reload|restart|kill|status}"
		echo "default mysql root password:$MysqlPassWord"
		echo "Prober : http://$IP/_tz.php"
		echo "phpinfo : http://$IP/_phpinfo.php"
		echo "phpMyAdmin : http://$IP/_phpmyadmin/"
		echo "Add VirtualHost : $IN_DIR/vhost.sh"
		echo ""
		echo "The path of some dirs:"
		echo "mysql dir:   $IN_DIR/$MYSQL_INITD"
		echo "php dir:     $IN_DIR/php"
		echo "nginx dir:   $IN_DIR/nginx"
		echo "web dir :    $IN_WEB_DIR/default"
		echo ""
		echo "========================================================================="
		$IN_DIR/lanmps status
		netstat -ntl
	else
		echo "Sorry,Failed to install LANMPS!"
		echo "Please visit http://bbs.lanmps.com feedback errors and logs."
		echo "You can download $LOGPATH from your server,And upload all the files in the directory to the Forum."
	fi
}
