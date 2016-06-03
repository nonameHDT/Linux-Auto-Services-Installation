#!/bin/bash

	/* 
	 * Viết bởi nonameHDT
	 * Release: 03/06/2016
	 *
	 * Script tự động cài đặt DNS service cho CentOS 6
	 */

	read -p "Domain (github.com): " domain
	read -p "This FQDN (server1.github.com): " fqdn
	read -p "Reverse Network (10.168.192):" reversenetwork
	
	$hname = `echo $fqdn | cut -d . -f 1`
	thishost=`ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
	lastoctet=`echo $thishost | cut -d . -f 4`
	yum install bind* -y
	wait

			
	cat > /etc/named.conf <<EOL
options
{
query-source port 53;
query-source-v6 port 53;
forwarders {8.8.8.8; };
directory	"/var/named";
dump-file	"/var/named/data/cache_dump.db";
statistics-file	"/var/named/data/named_stats.txt";
memstatistics-file	"/var/named/data/named_mem_stats.txt";
recursion no;
};

zone "." in {
type	hint;
file	"named.root";
};

zone "$domain" in {
type	master;
file	"$domain.db";
};

zone "$reversenetwork.in-addr.arpa" in {
type	master;
file	"$reversenetwork.db";
};

zone "localhost" in {
type master;
file "localhost.db";
};

zone "0.0.127.in-addr.arpa" in {
type master;
file "0.0.127.db";
};

EOL

	cat > /var/named/$domain.db <<EOL
\$TTL	86400
@	IN 	SOA	$fqdn. root (
			3;
			28800;
			7200;
			604800;
			86400;
)
; Name server's 

@	IN	NS	$fqdn.

; Name server hostname to IP resolve

@	IN	A	$thishost

; Hosts in Domain

$hname	IN	A	$thishost

www		IN	CNAME		$fqdn
EOL

	cat > /var/named/0.0.127.db <<EOL
\$TTL 86400
@	IN	SOA	localhost. root.localhost. (
			3;
			28800;
			7200;
			604800;
			86400;
)

	IN	NS 	localhost.
1	IN	PTR	localhost.
EOL

	cat > /var/named/named.root <<EOL
;       This file holds the information on root name servers needed to
;       initialize cache of Internet domain name servers
;       (e.g. reference this file in the "cache  .  <file>"
;       configuration file of BIND domain name servers).
;
;       This file is made available by InterNIC 
;       under anonymous FTP as
;           file                /domain/named.cache
;           on server           FTP.INTERNIC.NET
;       -OR-                    RS.INTERNIC.NET
;
;       last update:    Jun 8, 2011
;       related version of root zone:   2011060800
;
; formerly NS.INTERNIC.NET
;
.                        3600000  IN  NS    A.ROOT-SERVERS.NET.
A.ROOT-SERVERS.NET.      3600000      A     198.41.0.4
A.ROOT-SERVERS.NET.      3600000      AAAA  2001:503:BA3E::2:30
;
; FORMERLY NS1.ISI.EDU
;
.                        3600000      NS    B.ROOT-SERVERS.NET.
B.ROOT-SERVERS.NET.      3600000      A     192.228.79.201
;
; FORMERLY C.PSI.NET
;
.                        3600000      NS    C.ROOT-SERVERS.NET.
C.ROOT-SERVERS.NET.      3600000      A     192.33.4.12
;
; FORMERLY TERP.UMD.EDU
;
.                        3600000      NS    D.ROOT-SERVERS.NET.
D.ROOT-SERVERS.NET.      3600000      A     128.8.10.90
D.ROOT-SERVERS.NET.	 3600000      AAAA  2001:500:2D::D
;
; FORMERLY NS.NASA.GOV
;
.                        3600000      NS    E.ROOT-SERVERS.NET.
E.ROOT-SERVERS.NET.      3600000      A     192.203.230.10
;
; FORMERLY NS.ISC.ORG
;
.                        3600000      NS    F.ROOT-SERVERS.NET.
F.ROOT-SERVERS.NET.      3600000      A     192.5.5.241
F.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:2F::F
;
; FORMERLY NS.NIC.DDN.MIL
;
.                        3600000      NS    G.ROOT-SERVERS.NET.
G.ROOT-SERVERS.NET.      3600000      A     192.112.36.4
;
; FORMERLY AOS.ARL.ARMY.MIL
;
.                        3600000      NS    H.ROOT-SERVERS.NET.
H.ROOT-SERVERS.NET.      3600000      A     128.63.2.53
H.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:1::803F:235
;
; FORMERLY NIC.NORDU.NET
;
.                        3600000      NS    I.ROOT-SERVERS.NET.
I.ROOT-SERVERS.NET.      3600000      A     192.36.148.17
I.ROOT-SERVERS.NET.      3600000      AAAA  2001:7FE::53
;
; OPERATED BY VERISIGN, INC.
;
.                        3600000      NS    J.ROOT-SERVERS.NET.
J.ROOT-SERVERS.NET.      3600000      A     192.58.128.30
J.ROOT-SERVERS.NET.      3600000      AAAA  2001:503:C27::2:30
;
; OPERATED BY RIPE NCC
;
.                        3600000      NS    K.ROOT-SERVERS.NET.
K.ROOT-SERVERS.NET.      3600000      A     193.0.14.129
K.ROOT-SERVERS.NET.      3600000      AAAA  2001:7FD::1
;
; OPERATED BY ICANN
;
.                        3600000      NS    L.ROOT-SERVERS.NET.
L.ROOT-SERVERS.NET.      3600000      A     199.7.83.42
L.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:3::42
;
; OPERATED BY WIDE
;
.                        3600000      NS    M.ROOT-SERVERS.NET.
M.ROOT-SERVERS.NET.      3600000      A     202.12.27.33
M.ROOT-SERVERS.NET.      3600000      AAAA  2001:DC3::35
; End of File

EOL


	cat > /var/named/localhost.db <<EOL
\$TTL 86400
@	IN	SOA	@  root.(
			3;
			28800;
			7200;
			604800;
			86400;
)

	IN	NS 	@
	IN	A	127.0.0.1
	IN	AAAA	::1
EOL


	cat > /var/named/$reversenetwork.db <<EOL
\$TTL 86400
@	IN	SOA	$fqdn. root.(
			3;
			28800;
			7200;
			604800;
			86400;
)
; Name server's
@	IN	NS	$fqdn.
@	IN	PTR	$domain.

; Name server hostname to IP resolve.
$hname	IN	A	$thishost

; Hosts in Domain

$lastoctet	IN	PTR	$fqdn.
EOL

	iptables -A INPUT -i eth0 -p udp --dport 53 -j ACCEPT
	service iptables save
	
	chkconfig named on
	service named restart