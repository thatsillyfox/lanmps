. ./config.sh

# OS Version detect
# 1:redhat/centos 2:debian/ubuntu
OS_RL="centos"
grep -qi 'debian\|ubuntu' /etc/issue && OS_RL="ubuntu"
if [ $OS_RL = "centos" ]; then
    R6=0
    grep -q 'release 6' /etc/redhat-release && R6=1
fi
X86=0
if uname -m | grep -q 'x86_64'; then
    X86=1
fi

# detect script name, for install log
command=$(basename $0)
logpre=${command%%.sh}
#IP
#IP=$(ifconfig | awk -F'addr:|Bcast' '/Bcast/{print $2}')
IPS=`LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}'`
i=0;
for a in $IPS;
do
if [ "$i" = "0" ]; then
	IP=$a;
fi
i=$((i+1));
done;
IP=${IP// /}


#=================================================
. lib/fun.sh
. lib/Init.sh
. lib/Init_CheckAndDownloadFiles.sh
. lib/Install_DependsAndOpt.sh
. lib/Install_Mysql.sh
. lib/Install_Nginx.sh
. lib/Install_PHP.sh
. lib/Install_PHP_Tools.sh
. lib/Install_Memcached.sh
. lib/Install_Sphinx.sh
. lib/Starup.sh
clear
t_median=32
if [ $X86 = 1 ]; then
t_median=64
fi
MemTotal=`free -m | grep Mem | awk '{print  $2}'`
echo "LANMPS V0.1 for CentOS/Ubuntu Linux Written by Feng"
echo "========================================================================="
echo "A tool to auto-compile & install Apache+Nginx+MySQL+PHP on Linux "
echo "For more information please visit http://www.lanmps.com"
echo "========================================================================="
echo "Environmental Monitoring"
echo "IN_PWD: ${IN_PWD}"
echo "IN_DOWN: ${IN_DOWN}"
echo "LOGPATH: ${LOGPATH}"
echo "IN_DIR: ${IN_DIR}"
echo "IN_WEB_DIR: ${IN_WEB_DIR}"
echo "IN_WEB_LOG_DIR: ${IN_WEB_LOG_DIR}"
echo "Linux	: ${OS_RL} ${t_median}"
echo "Memory	: ${MemTotal}"
echo "IP	: $IP"
x1=`cat /etc/issue`
echo $x1
uname -a
echo "========================================================================="
unset t_median x1

if [[ "$START"x != "no"x  ]]; then

echo ""
#    1 Apache + php + mysql + opcache + phpmyadmin
#3 Nginx + apache + php + mysql + opcache + phpmyadmin
#4 install all service
echo "Select Install  ( 1 default ):
    1 Nginx + php + mysql + sphinx + opcache + memcache + phpmyadmin
    5 don't install is now"
sleep 0.1

read -p "Please Input 1,2,3,4,5: " SERVER_ID
if [ "$SERVER_ID" = "" ]; then
	SERVER_ID="1"
fi
SERVER_ID="1"
echo "Input $SERVER_ID"

if [[ $SERVER_ID == 1 ]]; then
    SERVER="nginx"
elif [[ $SERVER_ID == 2 ]]; then
    SERVER="apache"
elif [[ $SERVER_ID == 3 ]]; then
    SERVER="na"
elif [[ $SERVER_ID == 4 ]]; then
    SERVER="all"
else
    exit
fi

#PHP Version
echo
echo "Select php version:
    1 php-${VERS['php5.6.x']} (default)
    2 php-${VERS['php5.5.x']}
    3 php-${VERS['php5.4.x']}
    4 php-${VERS['php5.3.x']}
    5 don't install is now "
read -p "Please Input 1-5: " PHP_VER_ID
if [ "$PHP_VER_ID" = "" ]; then
	PHP_VER_ID="1"
fi

if [ "${PHP_VER_ID}" == "4" ]; then
    PHP_VER=${VERS['php5.3.x']}
	PHP_KEY="php5.3.x"
elif [ "${PHP_VER_ID}" == "2" ]; then
    PHP_VER=${VERS['php5.5.x']}
	PHP_KEY="php5.5.x"
	PHP_VER_ID=2
elif [ $PHP_VER_ID == "1" ]; then
    PHP_VER=${VERS['php5.6.x']}
	PHP_KEY="php5.6.x"
	PHP_VER_ID=1
else
    echo ${PHP_VER_ID}
	exit
fi
echo "Input $PHP_VER_ID  ,PHP_VER=${PHP_VER}"

echo "Select mysql :
    1 MySql 
    2 MariaDB (default)"
read -p "Please Input 1,2: " MYSQL_SELECT
MYSQL_INITD="mysql"
if [ $MYSQL_SELECT == "1" ]; then
	MYSQL_ID="mysql"
	MYSQL_SELECT=1
else
	MYSQL_ID="MariaDB"
	MYSQL_SELECT=2
fi
echo "Input $MYSQL_SELECT  ,MYSQL Name ${MYSQL_ID}"

echo "Select sphinx :
    1 sphinx ${VERS['sphinx']} 
    2 sphinx-for-chinese ${VERS['sphinx-for-chinese']} (default)
    3 sphinx-coreseek ${VERS['sphinx-coreseek']}
    4 no"
read -p "Please Input : " SPHINX_SELECT

if [ "$SPHINX_SELECT" = "" ]; then
	SPHINX_SELECT="2"
fi

if [ "$SPHINX_SELECT" == "1" ]; then
	SPHINX_ID="sphinx"
elif [ "$SPHINX_SELECT" == "2" ]; then
	SPHINX_ID="sphinx-for-chinese"
elif [ "$SPHINX_SELECT" == "3" ]; then
	SPHINX_ID="sphinx-coreseek"
	if [ "$OS_RL" == "ubuntu" ]; then
		SPHINX_ID=""
		echo " Coreseek cannot be installed on Ubuntu 14.x,13.x,12.x "
	fi
else
    SPHINX_ID=""
fi
echo "Input $SPHINX_SELECT  ,sphinx Name ${SPHINX_ID}"

#update source 
SOURCE_ID=1
echo
#echo "Select Update source :
#    1 Ubuntu default Update source ( default )
#    2 163.com Update source ( Chinese domestic Recommended )"
#read -p "Please Input 1,2: " SOURCE_ID
if [[ $SOURCE_ID == 2 ]]; then
    SOURCE_ID=2
else
    SOURCE_ID=1
fi
#echo "Input $SOURCE_ID"

fi

get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
echo "Press any key to start..."
char=`get_char`;

chmod 777 $IN_PWD/lib/*
chmod 777 $IN_PWD/down/*
if [ ! -d "$LOGPATH" ]; then
	mkdir $LOGPATH
	chmod +w $LOGPATH
else
    chmod +w $LOGPATH
fi