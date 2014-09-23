#!/bin/bash
# This script installs the Redis CLI

read -r -p "Install Redis CLI? (y/n) " INSTALL
  # If Database Alarms
  if [[ $INSTALL =~ ^([yY][eE][sS]|[yY])$ ]]; then
    wget http://download.redis.io/redis-stable.tar.gz
    tar xzf redis-stable.tar.gz
    cd redis-stable
    make  	
  else
  	echo "Cancelled."
  	exit 1
  fi
