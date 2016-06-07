#!/bin/bash

	yum install httpd -y
	wait
	
	yum install mod_ssl -y
	wait

	service httpd restart
	chkconfig httpd on

	iptables -A INPUT -i eth0 -p tcp --dport 80 --syn -j ACCEPT
	iptables -A INPUT -i eth0 -p tcp --dport 443 --syn -j ACCEPT

	service iptables save