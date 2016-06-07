#!/bin/bash

	clear
	
	echo -e "\e[32m"
	read -p "Domain (github.com): " domain
	read -p "Hostname (server1.github.com): " hname
	echo -e "\e[39m"
	
	netmask=`ip route | awk 'NR==1{print $1}'`
	thishost=`ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

	yum install wget -y

	wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
	rpm -Uvh epel-release-6-8.noarch.rpm remi-release-6.rpm
	wait

	yum remove sendmail -y
	wait

	yum install postfix dovecot httpd php squirrelmail -y
	wait
	
	echo "myhostname = $hname" >> /etc/postfix/main.cf
	echo "mydomain = $domain" >> /etc/postfix/main.cf
	echo "myorigin = \$mydomain" >> /etc/postfix/main.cf
	sed -i 's/^\(inet_interfaces\s*=\s*\).*$/\1all/' /etc/postfix/main.cf
	sed -i 's/^\(mydestination\s*=\s*\).*$/\1\$myhostname, localhost.\$mydomain, localhost, \$mydomain/' /etc/postfix/main.cf
	echo "mynetworks = $netmask, 127.0.0.0/8" >> /etc/postfix/main.cf
	echo "home_mailbox = Maildir/" >> /etc/postfix/main.cf
	
	echo "protocols = imap pop3 lmtp" >> /etc/dovecot/dovecot.conf
	echo "mail_location = maildir:~/Maildir" >> /etc/dovecot/conf.d/10-mail.conf
	echo "disable_plaintext_auth = no" >> /etc/dovecot/conf.d/10-auth.conf
	sed -i 's/^\(auth_mechanisms\s*=\s*\).*$/\1plain login/' /etc/postfix/main.cf
	
	cat >> /etc/httpd/conf/httpd.conf <<EOL
	Alias /webmail "/usr/share/squirrelmail"
	<Directory "/usr/share/squirrelmail">
		Options Indexes MultiViews FollowSymLinks
		RewriteEngine On
		DirectoryIndex index.php
		AllowOverride All
		Order allow,deny
		Allow from all
	</Directory>
EOL

	sed -i 's/^\(\$domain\s*=\s*\).*$/\1\"abc\.com\";/' /usr/share/squirrelmail/config/config.php
	sed -i 's/^\(\$useSendmail\s*=\s*\).*$/\1false;/' /usr/share/squirrelmail/config/config.php
	sed -i 's/^\(\$invert_time\s*=\s*\).*$/\1true;/' /usr/share/squirrelmail/config/config.php
	
	service postfix restart
	service dovecot restart
	service httpd restart
	
	iptables -A INPUT -p tcp --dport 25 -j ACCEPT
	iptables -A INPUT -p tcp --dport 110 -j ACCEPT
	iptables -A INPUT -p tcp --dport 995 -j ACCEPT
	iptables -A INPUT -p tcp --dport 143 -j ACCEPT
	iptables -A INPUT -p tcp --dport 993 -j ACCEPT
	iptables -A INPUT -p tcp --dport 80 -j ACCEPT
	
	service iptables save
	
	/usr/sbin/setsebool -P httpd_can_network_connect=1
	
	echo -e "\e[32m"
	echo "Now access webmail from address $thishost/webmail"
	echo -e "\e[39m"