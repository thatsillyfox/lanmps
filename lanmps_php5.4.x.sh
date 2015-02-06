#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/root/bin:~/bin
export PATH
# Check if user is root
START="no"
if [ $UID != 0 ]; then echo "Error: You must be root to run the install script, please use root to install lanmps";exit;fi
. lib/common.sh

PHP_KEY="php5.4.x"
PHP_VER=${VERS['php5.4.x']}
IN_DIR_SETS['php5.4.x']=${IN_DIR}/php54
SERVER="apache"

function Install_PHP54x()
{
tmp_configure=""
if [ $SERVER == "nginx" ]; then
	tmp_configure="--enable-fpm --with-fpm-user=www --with-fpm-group=www"
else
	tmp_configure="--with-apxs2=${IN_DIR}/apache/bin/apxs"
fi

echo "php-${VERS['php5.4.x']}.tar.gz"

cd $IN_DOWN
tar zxvf php-${PHP_VER}.tar.gz
cd php-${PHP_VER}/
./configure --prefix="${IN_DIR_SETS['php5.4.x']}" \
--with-config-file-path="${IN_DIR_SETS['php5.4.x']}" \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-iconv-dir=/usr/local/libiconv \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-mbstring \
--with-mcrypt \
--enable-ftp \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--without-pear \
--with-gettext \
--disable-fileinfo $tmp_configure

make
make install

php_ini="${IN_DIR_SETS['php5.4.x']}/php.ini"
echo "Copy new php configure file. $php_ini "
cp php.ini-production $php_ini

echo "Modify php.ini......"
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' $php_ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' $php_ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' $php_ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' $php_ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' $php_ini
sed -i 's/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' $php_ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' $php_ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $php_ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' $php_ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' $php_ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' $php_ini
sed -i 's:mysql.default_socket =:mysql.default_socket ='$IN_DIR'/mysql/data/mysql.sock:g' $php_ini
sed -i 's/expose_php/;expose_php/g' $php_ini

ln -s $php_ini $IN_DIR/etc/php5.4.x.ini

#PHP-FPM
if [ $SERVER == "nginx" ]; then



echo "MV php-fpm.conf file"
conf=$IN_DIR/php/etc/php-fpm.conf;
mv $IN_DIR/php/etc/php-fpm.conf.default $conf

sed -i 's:;pid = run/php-fpm.pid:pid = run/php-fpm.pid:g' $conf
sed -i 's:;error_log = log/php-fpm.log:error_log = '"$IN_WEB_LOG_DIR"'/php-fpm.log:g' $conf
sed -i 's:;log_level = notice:log_level = notice:g' $conf
sed -i 's:pm.max_children = 5:pm.max_children = 10:g' $conf
sed -i 's:pm.max_spare_servers = 3:pm.max_spare_servers = 6:g' $conf
sed -i 's:;request_terminate_timeout = 0:request_terminate_timeout = 100:g' $conf

ln -s $IN_DIR/php/etc/php-fpm.conf $IN_DIR/etc/php-fpm.conf

echo "Copy php-fpm init.d file......"
cp "${IN_DOWN}/php-${PHP_VER}/sapi/fpm/init.d.php-fpm" $IN_DIR/init.d/php-fpm
chmod +x $IN_DIR/init.d/php-fpm
if [ $ETC_INIT_D_LN = 1 ]; then
	ln -s $IN_DIR/init.d/php-fpm /etc/init.d/php-fpm
fi
if [ ! $IN_DIR = "/www/lanmps" ]; then
	sed -i "s:/www/lanmps:$IN_DIR:g" $IN_DIR/init.d/php-fpm
fi

fi
#PHP-FPM
unset php_ini conf
}

function Install_PHP_Tools()
{
	local php_ini=${IN_DIR_SETS['php5.4.x']}/php.ini
	
	echo "Install memcache php extension..."
	
	echo "tar zxvf memcache-${VERS['memcache']}.tgz"
	cd $IN_DOWN
	tar zxvf memcache-${VERS['memcache']}.tgz
	cd memcache-${VERS['memcache']}
	${IN_DIR_SETS['php5.4.x']}/bin/phpize
	./configure --enable-memcache --with-php-config=${IN_DIR_SETS['php5.4.x']}/bin/php-config --with-zlib-dir
	make && make install

	local php_v=`${IN_DIR_SETS['php5.4.x']}/bin/php -v`
	local php_ext_date="20131226"
	sed -i 's#; extension_dir = "./"#extension_dir = "./"#' $php_ini
	echo "${IN_DIR_SETS['php5.4.x']}/bin/php -v"
	echo $php_v
	if echo "$php_v" | grep -q "5.6."; then
		php_ext_date="20131226"
	elif echo "$php_v" | grep -q "5.5."; then
		php_ext_date="20121212"
	elif echo "$php_v" | grep -q "5.4."; then
		php_ext_date="20100525"
	elif echo "$php_v" | grep -q "5.3."; then
		php_ext_date="20090626"
	elif echo "$php_v" | grep -q "5.2."; then
		php_ext_date="20060613"
	fi

	if [ "$php_ext_date" == "200906261" ]; then
	    echo "ddd"
	else
	    php_ext_date="no-debug-non-zts-${php_ext_date}"
	fi

	sed -i 's#extension_dir = "./"#extension_dir ='${IN_DIR_SETS['php5.4.x']}'/lib/php/extensions/'$php_ext_date'/\nextension =memcache.so\n#' $php_ini
	echo 's#extension_dir = "./"#extension_dir = "'${IN_DIR_SETS['php5.4.x']}'/lib/php/extensions/'$php_ext_date'/"\nextension = memcache.so\n#'

}


function Starup()
{
	echo "Set start"
}


{ 
 

Install_PHP54x;

Install_PHP_Tools;

 }  2>&1 | tee -a "${LOGPATH}/other.php5.4.x.Install.log"
 
echo "ok"
echo "ok"
echo "ok"
echo "ok"
echo "ok"
echo "ok"