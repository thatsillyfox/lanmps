#!/bin/bash
# Web Server Install Script
if [ $UID != 0 ]; then echo "Error: You must be root to run the install script, please use root to install lanmps";exit;fi

PS_SERVER=`ps ax | grep nginx.conf | grep -v "grep"`
if [[ $PS_SERVER ]];then
	SERVER="nginx"
else
	SERVER="apache"
fi
IN_DIR="/www/lanmps"
IN_WEB_DIR="/www/wwwroot"
IN_WEB_LOG_DIR="/www/wwwLogs"
CONF_DIR="$IN_DIR/$SERVER/conf/vhost"

clear
echo 
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Add Virtual Host for linux or lanmps "
echo "---------------------------------------------------------------"
echo "linux is a customized version of CentOS based, for quick, easy to install web server system"
echo "lanmps is a tool to auto-compile & install lamp or lnmp on linux"
echo "This script is a tool add virtual host for linux"
echo "For more information please visit http://www.lanmps.com"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo "The server is running $SERVER"
echo "----------------------------------------------------------------"
echo

echo "Pleast input domain:"
read -p "(Default or Example domain:www.lanmps.com):" domain
if [[ $domain == "" ]];then
	domain="www.lanmps.com"
fi
echo 
echo "domain:$domain"
echo "-----------------------------------------"
echo
sdomain=${domain#www.}
if [[ -f "$CONF_DIR/$domain.conf" ]];then
	echo "$CONF_DIR/$domain.conf is exists!"
	exit
fi

echo "Do you want to add more domain name? (y/n)"
read more_domain
if [[ $more_domain == "y" || $more_domain == "Y" ]];then
	echo "Input domain name,example(bbs.lanmps.com blog.lanmps.com):"
	read domain_a
	domain_alias=${sdomain}" "${domain_a}
fi
echo
echo "domain alias:$domain_alias"
echo "-----------------------------------------"
echo

echo "Allow access_log? (y/n)"
read access_log
if [[ $access_log == "y" || $access_log == "Y" ]];then
	nginx_log="#log_format  $domain  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" \$status \$body_bytes_sent \"\$http_referer\" \"\$http_user_agent\" \$http_x_forwarded_for';
	access_log  ${IN_WEB_LOG_DIR}/$domain.log  access;"
	apache_log="    ErrorLog \"${IN_WEB_LOG_DIR}/logs/$domain/_error.error_log\"
    CustomLog \"|/${IN_DIR}/apache/bin/rotatelogs ${IN_WEB_LOG_DIR}/logs/$domain/%Y_%m_%d.access.log 86400\" common"
	echo
	echo "access_log dir:"$IN_WEB_LOG_DIR/logs/$domain/Y_m_d.log
	echo "------------------------------------------"
	echo
else
	nginx_log="access_log off;"
	apache_log=""
fi

#echo "Do you want to add ftp Account? (y/n)"
#read ftp_account
#if [[ $ftp_account == "y" || $ftp_account == "Y" ]];then
#	read -p "ftp user name:" ftp_user
#	read -p "ftp user password:" ftp_pass
#	useradd -d $IN_WEB_DIR/$domain -s /sbin/nologin $ftp_user
#	echo "$ftp_pass" | passwd --stdin $ftp_user
#	chmod 755 $IN_WEB_DIR/$domain
#	echo
#else
#	echo "Create virtual host directory."
#	mkdir -p $IN_WEB_DIR/$domain
#	chown -R www:www $IN_WEB_DIR/$domain
#fi

echo "Create virtual host directory."
mkdir -p $IN_WEB_LOG_DIR/logs/$domain
mkdir -p $IN_WEB_DIR/$domain
chown -R www:www $IN_WEB_DIR/$domain

if [[ $SERVER == "nginx" ]];then
cat > $CONF_DIR/$domain.conf<<eof
server
{
	listen       80;
	server_name $domain $domain_alias;
	
	root  $IN_WEB_DIR/$domain;

	location / {
		index index.html index.htm index.php default.html default.htm default.php;
	}
	
	location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$ {
		expires      30d;
	}

	location ~ .*\.(js|css)?$ {
		expires      12h;
	}
	
	location ~ \.php$ {
		#fastcgi_pass   127.0.0.1:9000;
		#fastcgi_pass  unix:/tmp/php-cgi.sock;
		fastcgi_pass   bakend;
		fastcgi_index index.php;
		include fastcgi.conf;
	}
	include $IN_WEB_DIR/$domain/lanmps-*.conf;
	$nginx_log
}
eof
else
cat > $CONF_DIR/$domain.conf<<eof
<VirtualHost *:80>
DocumentRoot "$IN_WEB_DIR/$domain"
ServerName $domain
ServerAlias $domain_alias
directoryIndex  index.html index.php index.htm
$apache_log
	<Directory $IN_WEB_DIR/$domain>
		Options -Indexes
		AllowOverride All
		Require all granted
	</Directory>
</VirtualHost>
eof
fi

cat > $IN_WEB_DIR/$domain/index.html<<eof
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<title>test page - www.lanmps.com</title>
</head>

<body>
<div align="center">
  <h1>test page of $domain  </h1>
  <p>Create by vhost.sh of <a href="http://www.lanmps.com" target="_blank">www.lanmps.com</a> </p>
</div>
</body>
</html>
eof
if [[ $ftp_account == "y" || $ftp_account == "Y" ]];then
	chown $ftp_user $IN_WEB_DIR/$domain/index.html
fi

if [[ $SERVER == "nginx" ]];then
	/etc/init.d/php-fpm restart
	$IN_DIR/nginx/sbin/nginx -s reload
else
	service httpd restart
fi

echo
echo
echo
echo "web site infomations:"
echo "========================================"
echo "domain list:$domain $domain_alias"
echo "----------------------------------------"
echo "website dir:$IN_WEB_DIR/$domain"
echo "----------------------------------------"
echo "conf file:$CONF_DIR/$domain.conf"
echo "----------------------------------------"
if [[ $access_log == "y" || $access_log == "Y" ]];then
	echo "access_log:$IN_WEB_LOG_DIR/$domain.log"
	echo "----------------------------------------"
fi
if [[ $ftp_account == "y" || $access_log == "Y" ]];then
	echo "ftp user:$ftp_user password:$ftp_pass";
	echo "----------------------------------------"
fi
echo "web site is OK"
echo "For more information please visit http://www.lanmps.com"
echo "========================================"
