#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/root/bin:~/bin
export PATH
# Check if user is root
if [ $UID != 0 ]; then echo "Error: You must be root to run the install script, please use root to install lanmps";exit;fi

iptables-save >> _.iptables.up.rules #保存防火墙设置,以便没保存时使用
iptables -L -n 2>&1 | tee -a "_.iptables.log"
iptables -F        #清除预设表filter中的所有规则链的规则
iptables -X        #清除预设表filter中使用者自定链中的规则
iptables -Z        #计数器清零

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
#允许本机
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
#FTP
iptables -A INPUT -p tcp --dport 21 -j ACCEPT
#SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
#80
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

#13306 映射转发到  mysql数据库 3306
#iptables -A PREROUTING -p tcp --dport 13306 -j REDIRECT --to-ports 3306 -t nat
#3306 mysql数据库
#iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
#memache
#iptables -A INPUT -p tcp --dport 11211 -j ACCEPT

#对于OUTPUT规则，因为预设的是ACCEPT，所以要添加DROP规则，减少不安全的端口链接。
iptables -A OUTPUT -p tcp --sport 31337 -j DROP
iptables -A OUTPUT -p tcp --dport 31337 -j DROP

#丢弃坏的TCP包
iptables -A FORWARD -p tcp ! --syn -m state --state NEW -j DROP
#处理IP碎片数量,防止攻击,允许每秒100个
#iptables -A FORWARD -f -m limit --limit 100/s --limit-burst 100 -j ACCEPT

#设置ICMP包过滤,允许每秒1个包,限制触发条件是10个包
#iptables -A FORWARD -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT

#防止外部的ping和SYN洪水攻击
iptables -A INPUT -p tcp --syn -m limit --limit 100/s --limit-burst 100 -j  ACCEPT
#ping洪水攻击，限制每秒的ping包不超过10个
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s –limit-burst 10 -j ACCEPT
#防止各种端口扫描，将SYN及ACK SYN限制为每秒钟不超过200个
iptables -A INPUT -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -m limit --limit 20/sec --limit-burst 200 -j ACCEPT

#最后规则拒绝所有不符合以上所有的  
iptables -A INPUT -j DROP
if [ -z "`grep "iptables-save" /etc/network/interfaces`" ]
then
	echo "#以下有防火墙需要的可以使用  
pre-up iptables-restore < /etc/iptables.up.rules #启动时应用防火墙  
post-down iptables-save > /etc/iptables.up.rules #关闭时保存防火墙设置,以便下次启动时使用  " >> /etc/network/interfaces
    
else
     echo "iptables-save find "
fi

clear
echo "iptables ok ";
echo ""

iptables -L -n
cat /etc/network/interfaces