#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/root/bin:~/bin
export PATH
# Check if user is root
START="no"
if [ $UID != 0 ]; then echo "Error: You must be root to run the install script, please use root to install lanmps";exit;fi
. lib/common.sh

PHP_KEY="php5.3.x"
PHP_VER=${VERS['php5.3.x']}
IN_DIR_SETS['php5.3.x']=${IN_DIR}/php53

function Install_PHP_Tools()
{
	local php_ini=${IN_DIR_SETS['php5.3.x']}/php.ini
	
	echo "Install memcache php extension..."
	
	echo "tar zxvf memcache-${VERS['memcache']}.tgz"
	cd $IN_DOWN
	tar zxvf memcache-${VERS['memcache']}.tgz
	cd memcache-${VERS['memcache']}
	${IN_DIR_SETS['php5.3.x']}/bin/phpize
	./configure --enable-memcache --with-php-config=${IN_DIR_SETS['php5.3.x']}/bin/php-config --with-zlib-dir
	make && make install

	local php_v=`${IN_DIR_SETS['php5.3.x']}/bin/php -v`
	local php_ext_date="20131226"
	sed -i 's#; extension_dir = "./"#extension_dir = "./"#' $php_ini
	echo "${IN_DIR_SETS['php5.3.x']}/bin/php -v"
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
	sed -i 's#extension_dir = "./"#extension_dir = "'${IN_DIR_SETS['php5.3.x']}'/lib/php/extensions/no-debug-non-zts-'$php_ext_date'/"\nextension = "memcache.so"\n#' $php_ini
	echo 's#extension_dir = "./"#extension_dir = "'${IN_DIR_SETS['php5.3.x']}'/lib/php/extensions/no-debug-non-zts-'$php_ext_date'/"\nextension = "memcache.so"\n#'
	
	echo "Install xdebug php extension..."
	cd $IN_DOWN
	tar zxvf xdebug-${VERS['xdebug']}.tgz
	cd xdebug-${VERS['xdebug']}
	${IN_DIR}/php/bin/phpize
	./configure --enable-xdebug --with-php-config=${IN_DIR_SETS['php5.3.x']}/bin/php-config
	make && make install
	echo '
[Xdebug]
;zend_extension="'${IN_DIR_SETS['php5.3.x']}'/lib/php/extensions/no-debug-zts-'$php_ext_date'/xdebug.so"
;xdebug.auto_trace=1
;xdebug.collect_params=1
;xdebug.collect_return=1
;xdebug.trace_output_dir = "'$IN_WEB_LOG_DIR'"
;xdebug.profiler_enable=1
;xdebug.profiler_output_dir = "'$IN_WEB_LOG_DIR'" 
;xdebug.max_nesting_level=10000
;xdebug.remote_enable=1
;xdebug.remote_autostart = 0
;xdebug.remote_host=localhost
;xdebug.remote_port=9033
;xdebug.remote_handler=dbgp
;xdebug.idekey="PHPSTORM"  
' >> $php_ini
	

}
function Starup()
{
	echo "============================add php-fpm-53 on startup============================"
	echo "Set start"
	if [ $OS_RL = "centos" ]; then
		chkconfig --level 345 php-fpm-53 on
	else
		update-rc.d -f php-fpm-53 defaults
	fi
}


{ 
 

Install_PHP;

Install_PHP_Tools;

Starup;

 }  2>&1 | tee -a "${LOGPATH}/other.php5.3.x.Install.log"
 
echo "ok"
echo "ok"
echo "ok"
echo "ok"
echo "ok"
echo "ok"