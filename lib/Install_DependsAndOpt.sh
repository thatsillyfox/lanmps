function Install_DependsAndOpt()
{
	local IN_LOG=$LOGPATH/install_Install_DependsAndOpt.sh.lock
    echo
    [ -f "$IN_LOG" ] && return
	
	/sbin/ldconfig
	
	[ ! -s /usr/lib/libmcrypt.la ] && ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
	[ ! -s /usr/lib/libmcrypt.so ] && ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
	[ ! -s /usr/lib/libmcrypt.so.4 ] && ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
	[ ! -s /usr/lib/libmcrypt.so.4.4.8 ] && ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8

	cd $IN_DOWN

	if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
		ln -s /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/
		ln -s /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/
	else
		ln -s /usr/lib/i386-linux-gnu/libpng* /usr/lib/
		ln -s /usr/lib/i386-linux-gnu/libjpeg* /usr/lib/
	fi

	ulimit -v unlimited

	if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
		echo "/lib" >> /etc/ld.so.conf
	fi

	if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
		echo "/usr/lib" >> /etc/ld.so.conf
	fi

	if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
		echo "/usr/lib64" >> /etc/ld.so.conf
	fi

	if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
		echo "/usr/local/lib" >> /etc/ld.so.conf
	fi

	ldconfig

	cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

	cat >>/etc/sysctl.conf<<eof
fs.file-max=65535
eof
	touch $IN_LOG
}