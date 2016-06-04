#!/bin/bash

	/*
	 * Written by nonameHDT
	 * Release: 04/06/2016
	 * Auto reconfigure eth1 interface to eth0 interface after cloneing in vmWare
	 */
		read -p "This host IP: " thisip
		read -p "DNS IP: " dnsip
		eth1=`ifconfig | grep eth1`
		if [ "$eth1" != "" ]
		then 
		
			hwaddr=`ifconfig eth1 | grep HWaddr | awk '{print $5}'`
			
			cat > /etc/udev/rules.d/70-persistent-net.rules <<EOL
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="$hwaddr", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"
EOL
			
			cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOL
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
HWADDR=$hwaddr
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"
IPADDR=$thisip
NETMASK=255.255.255.0
GATEWAY=192.168.10.2
DNS1=$dnsip
EOL
		fi

		read -p "New hostname: " hname  
		echo $hname > /etc/sysconfig/network
		wait
		reboot
	
