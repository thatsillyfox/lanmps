# mysql install function
function Install_Mysql {
	local IN_LOG=$LOGPATH/install_Install_Mysql.sh.lock
	echo
    [ -f $IN_LOG ] && return
	
    echo "============================Install MySQL ${VERS['mysql']}=================================="
	echo "Delete the old configuration files and directory   /etc/my.cnf /etc/mysql/my.cnf /etc/mysql/"
	[ -s /etc/my.cnf ] && rm /etc/my.cnf
	[ -s /etc/mysql/my.cnf ] && rm /etc/mysql/my.cnf
	[ -e /etc/mysql/ ] && rm -rf /etc/mysql/
	
	cd $IN_DOWN
	tar zxvf mysql-${VERS['mysql']}.tar.gz
	cd mysql-${VERS['mysql']}/
	cmake . \
	-DCMAKE_INSTALL_PREFIX=$IN_DIR/mysql \
	-DMYSQL_DATADIR=$IN_DIR/mysql/data \
	-DSYSCONFDIR=$IN_DIR/mysql \
	-DMYSQL_UNIX_ADDR=$IN_DIR/mysql/data/mysql.sock \
	-DMYSQL_TCP_PORT=3306 \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	-DWITH_MEMORY_STORAGE_ENGINE=1 \
	-DWITH_PARTITION_STORAGE_ENGINE=1 \
	-DEXTRA_CHARSETS=all \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DWITH_READLINE=1 \
	-DWITH_SSL=system \
	-DWITH_ZLIB=system \
	-DMYSQL_USER=mysql \
	-DWITH_EMBEDDED_SERVER=1 \
	-DENABLED_LOCAL_INFILE=1
	make && make install

	cnf=$IN_DIR/mysql/my.cnf
	cp support-files/my-medium.cnf $cnf
	ln -s $cnf $IN_DIR/etc/my.cnf
	sed -i "s:skip-external-locking:#skip-external-locking:g" $cnf
	
	if [ $INNODB_ID = 2 ]; then
		sed -i 's:#innodb:innodb:g' $cnf
		sed -i 's#ibdata1:10M:autoextend#ibdata1:1000M:autoextend#g' $cnf
		sed -i 's#innodb_buffer_pool_size = 16M#innodb_buffer_pool_size = 1024M#g' $cnf
		sed -i 's#innodb_log_file_size = 5M#innodb_log_file_size = 256M#g' $cnf
		sed -i 's#innodb_log_buffer_size = 8M#innodb_log_buffer_size = 64M#g' $cnf
		sed -i '/innodb_lock_wait_timeout = 50/ainnodb_file_per_table = 1\nlong_query_time=1\ninnodb_log_files_in_group=2' $cnf
	else
		sed -i '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' $cnf
	fi

	$IN_DIR/mysql/scripts/mysql_install_db --defaults-file=$cnf --basedir=$IN_DIR/mysql --datadir=$IN_DIR/mysql/data --user=mysql
	chown -R mysql $IN_DIR/mysql/data
	chgrp -R mysql $IN_DIR/mysql/.
	
	cp support-files/mysql.server $IN_DIR/init.d/mysql
	chmod 755 $IN_DIR/init.d/mysql
	if [ $ETC_INIT_D_LN = 1 ]; then
		ln -s $IN_DIR/init.d/mysql /etc/init.d/mysql
	fi

	cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${IN_DIR}/mysql/lib
/usr/local/lib
EOF

	ldconfig

	ln -s $IN_DIR/mysql/lib/mysql /usr/lib/mysql
	ln -s $IN_DIR/mysql/include/mysql /usr/include/mysql
	if [ -d "/proc/vz" ];then
		ulimit -s unlimited
	fi
	
	#start
	$IN_DIR/init.d/mysql start
	
	ln -s $IN_DIR/mysql/bin/mysql /usr/bin/mysql
	ln -s $IN_DIR/mysql/bin/mysqldump /usr/bin/mysqldump
	ln -s $IN_DIR/mysql/bin/myisamchk /usr/bin/myisamchk
	ln -s $IN_DIR/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

	$IN_DIR/mysql/bin/mysqladmin -u root password $MysqlPassWord

	cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$MysqlPassWord') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

	$IN_DIR/mysql/bin/mysql -u root -p$MysqlPassWord -h localhost < /tmp/mysql_sec_script

	rm -f /tmp/mysql_sec_script
	
	$IN_DIR/init.d/mysql restart
	$IN_DIR/init.d/mysql stop
	echo "============================MySQL ${VERS['mysql']} install completed========================="
	touch $IN_LOG
}
