# mysql install function
function Install_Mysql {
	local IN_LOG=$LOGPATH/install_Install_Mysql.sh.lock
	echo
    [ -f "$IN_LOG" ] && return
	
    echo "============================Install MySQL ${VERS['mysql']}=================================="
	
	echo "Input $MYSQL_SELECT"
	echo "Install $MYSQL_ID ${VERS[$MYSQL_ID]} "
	echo "${IN_PWD}/lib/Install_Mysql-${MYSQL_ID}.sh"
	
	import "${IN_PWD}/lib/Install_Mysql-${MYSQL_ID}.sh"
	
	echo "============================MySQL ${VERS['mysql']} install completed========================="
	touch $IN_LOG
}
