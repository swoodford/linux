#!/bin/bash
# This script installs New Relic monitoring agent on a server

KEY="your New Relic key here"


read -r -p "Install New Relic monitoring agent? (y/n) " INSTALL
  if [[ $INSTALL =~ ^([yY][eE][sS]|[yY])$ ]]; then
  	sudo rpm -Uvh http://download.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm
  	sudo yum install newrelic-sysmond -y
  	sudo nrsysmond-config --set license_key=$KEY
  	sudo /etc/init.d/newrelic-sysmond start
  	else
  	echo "Cancelled."
  	exit 1
  fi
