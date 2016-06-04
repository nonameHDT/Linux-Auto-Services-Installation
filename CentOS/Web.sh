#!/bin/bash

# Written by nonameHDT
# Release: 04/06/2016
# Auto install Web service for CentOS

	echo -e "\e[32mInstalling Apache\e[39m"
	echo ""
	yum install httpd -y
	wait
	echo ""

	while true; do
		echo -e "\e[32m"
    		read -p "Install https? (y/n): " yn
		echo -e "\e[39m"
    		case $yn in
        		[Yy]* ) echo -e "\e[32mInstalling SSL module\e[39m"; echo ""; yum install mod_ssl -y; wait; break;;
        		[Nn]* ) exit;;
        		* ) echo -e "\e[32mPlease answer y or n.\e[39m";;
    		esac
	done

	echo ""
	echo -e "\e[32mDone.\e[39m"
