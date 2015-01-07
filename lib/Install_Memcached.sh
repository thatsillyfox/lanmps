function Install_Memcached()
{
	echo "=========================== install memcached ======================"
	echo "=========================== install memcached ======================"
	echo "=========================== install memcached ======================"
	local IN_LOG=$LOGPATH/install_Install_Memcache.sh.lock
	echo
    [ -f "$IN_LOG" ] && return
	

	local Memcached_DIR=$IN_DIR/memcached
	

	ProgramIsInstalled "libevent" "libevent-${VERS['libevent']}-stable.tar.gz"

	ProgramInstalled "libevent" "libevent-${VERS['libevent']}-stable.tar.gz" "--prefix=/usr/local/libevent" "libevent-${VERS['libevent']}-stable.tar.gz"

	echo "/usr/local/libevent/lib/" >> /etc/ld.so.conf
	ln -s /usr/local/libevent/lib/libevent-2.0.so.5  /lib/libevent-2.0.so.5
	ldconfig
	
	echo "======================================================="
	ProgramDownloadFiles "memcached" "memcached-${VERS['memcached']}.tar.gz"

	ProgramInstalled "memcached" "memcached-${VERS['memcached']}.tar.gz" "--with-libevent=/usr/local/libevent --prefix=${Memcached_DIR}"

	ln $Memcached_DIR/bin/memcached /usr/bin/memcached
	local cnf="$IN_DIR/init.d/memcached"
	if [ $OS_RL = "centos" ]; then
		cp $IN_PWD/conf/init.d.memcached $cnf
	else
		cp $IN_PWD/conf/init.d.memcached-ubuntu $cnf
	fi
	if [ ! $IN_DIR = "/www/lanmps" ]; then
		sed -i "s:/www/lanmps:$IN_DIR:g" $cnf
	fi
	chmod 755 $cnf
	ln -s $cnf /etc/init.d/memcached
	cp $IN_PWD/conf/conf.memcached.conf $IN_DIR/etc/memcached.conf
	if [ ! $IN_DIR = "/www/lanmps" ]; then
		sed -i "s:/www/lanmps:$IN_DIR:g" $IN_DIR/etc/memcached.conf
	fi
	
	echo "Copy Memcached PHP Test file..."
	cp $IN_PWD/conf/php.memcached.php $IN_WEB_DIR/default/memcached.php

	touch $IN_LOG
	echo "=========================== install memcached ======================"
	echo "=========================== install memcached ======================"
	echo "=========================== install memcached ======================"
}