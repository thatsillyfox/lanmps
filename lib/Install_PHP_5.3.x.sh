cd $IN_DOWN
tar zxvf php-${VERS['php5.3']}.tar.gz
cd php-${VERS['php5.3']}/
./configure \
--prefix=${IN_DIR}/php \
--with-config-file-path=${IN_DIR}/php \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath \
--enable-magic-quotes \
--enable-safe-mode \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--with-curlwrappers \
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
--disable-fileinfo

make ZEND_EXTRA_LIBS='-liconv'
make install

[ -e /usr/bin/php ] && rm -f /usr/bin/php
ln -s ${IN_DIR}/php/bin/php /usr/bin/php
ln -s ${IN_DIR}/php/bin/phpize /usr/bin/phpize
ln -s ${IN_DIR}/php/sbin/php-fpm /usr/bin/php-fpm

echo "Copy new php configure file."
php_ini="${IN_DIR}/php/php.ini"

cp php.ini-production $php_ini

cd $cur_dir
# php extensions
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

ln -s $php_ini $IN_DIR/etc/php.ini

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
unset php_ini conf