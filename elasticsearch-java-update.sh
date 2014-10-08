#!/bin/bash

# This script will update Java from 1.6.0 to 1.7.0 if necessary and update Elasticsearch to the latest version using the yum repo

echo "============================="
echo "           Java"
echo "============================="

# Need to find a reliable way to determine the latest version of Java available through Yum
# Until then hardcoding this version
latestjavaversion=1.7.0_65

# Determine the installed and active version of Java on the local machine
installedjavaversion=$(java -version 2>&1 | awk '/version/{print $NF}' | cut -c 2-9)

if [[ -z $installedjavaversion ]]; then
  echo "Error: Unable to determine installed Java version!"
else
  echo "Installed Java Version: "$installedjavaversion
fi

if [[ "$installedjavaversion" == "$latestjavaversion" ]]; then
  echo "Installed Java version matches latest version."
else
  # echo "Installed Java Version: "$installedjavaversion
  echo "Need to update Java!"
  echo "Attempting to switch versions using alternatives..."
  sudo alternatives --config java

  read -r -p "Continue install or update Java to 1.7? (y/n) " updatejava
  if [[ $updatejava =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo yum remove java-1.6.0-openjdk -y
    sudo yum install java-1.7.0-openjdk -y
    sudo alternatives --config java
  elif [[ $updatejava =~ ^([nN][oO]|[nN])$ ]]; then
    echo "Skipping Java update."
  else
    echo "Error: Invalid Response!"
    exit 1
  fi
fi
echo " "
echo "============================="
echo "       Elasticsearch"
echo "============================="

# Determine the latest version of Elasticsearch from the GitHub repo
latestelasticsearchversion=$(curl -s "https://api.github.com/repos/elasticsearch/elasticsearch/tags" | grep -m 1 v | cut -c15-19)

if [[ -z $latestelasticsearchversion ]]; then
  echo "Error: Unable to determine latest Elasticsearch version!"
  exit 1
else
  echo "Latest Elasticsearch Version in GitHub Repo: "$latestelasticsearchversion
fi

# Determine the installed version of Elasticsearch on the local machine
installedelasticsearchversion=$(curl -sX GET http://localhost:9200/ | grep number | cut -d "\"" -f4)
if [[ -z $installedelasticsearchversion ]]; then
  echo "Error: Unable to determine installed Elasticsearch version!"
  # exit 1
else
  echo "Installed Elasticsearch Version: "$installedelasticsearchversion
fi

# Determine if the installed version of Elasticsearch is less than the latest version in GitHub
if [[ "$installedelasticsearchversion" == "$latestelasticsearchversion" ]]; then
  echo "Installed Elasticsearch version matches latest version."
else
  echo "Need to install or update Elasticsearch!"
  # echo "Error: Unable to compare versions!"
  # exit 1
  read -r -p "Attempt to update Elasticsearch through yum? (y/n) " updateelasticsearchyum
  if [[ $updateelasticsearchyum =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo yum update elasticsearch -y
    installedelasticsearchversionyum=$(curl -sX GET http://localhost:9200/ | grep number | cut -d "\"" -f4)
    if [[ -z $installedelasticsearchversionyum ]]; then
      echo "Error: Unable to determine installed Elasticsearch version!"
      # exit 1
    else
      echo "Yum Installed Elasticsearch Version: "$installedelasticsearchversionyum
    fi

    if [[ "$installedelasticsearchversionyum" == "$latestelasticsearchversion" ]]; then
      echo "Installed Elasticsearch version now matches latest version."
      exit 1
    # else
    #   echo "Installed Elasticsearch version does not match latest version."
    # elif [[ $updateelasticsearchyum =~ ^([nN][oO]|[nN])$ ]]; then
    #   echo "Skipping Elasticsearch yum update."
  fi
fi

# # Don't install 1.2
# read -r -p "Uninstall and update Elasticsearch to 1.2.x? (y/n) " updateelasticsearch
# if [[ $updateelasticsearch =~ ^([yY][eE][sS]|[yY])$ ]]; then
#   sudo yum remove elasticsearch -y
#   sleep 6

#   elasticsearchold="/var/log/elasticsearchold"
#   if [ ! -d "$elasticsearchold" ]; then
#     sudo mv /var/log/elasticsearch /var/log/elasticsearchold
#   fi

#   sudo rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch

#   REPO="~/elasticsearch.repo"
#   if [ -f $REPO ]; then
#     rm ~/elasticsearch.repo
#     sudo rm /etc/yum.repos.d/elasticsearch.repo
#   fi

#   touch ~/elasticsearch.repo
#   echo "[elasticsearch-1.2]" >> ~/elasticsearch.repo
#   echo "name=Elasticsearch repository for 1.2.x packages" >> ~/elasticsearch.repo
#   echo "baseurl=http://packages.elasticsearch.org/elasticsearch/1.2/centos" >> ~/elasticsearch.repo
#   echo "gpgcheck=1" >> ~/elasticsearch.repo
#   echo "gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch" >> ~/elasticsearch.repo
#   echo "enabled=1" >> ~/elasticsearch.repo
#   sudo mv ~/elasticsearch.repo /etc/yum.repos.d/

#   sudo yum install elasticsearch -y
#   sleep 10
#   sudo service elasticsearch start
#   sleep 3
#   sudo /sbin/chkconfig --add elasticsearch
#   sleep 3
#   sudo /usr/share/elasticsearch/bin/elasticsearch -d &
# else
read -r -p "Uninstall and update Elasticsearch to 1.3.x? (y/n) " updateelasticsearch3
if [[ $updateelasticsearch3 =~ ^([yY][eE][sS]|[yY])$ ]]; then
  sudo yum remove elasticsearch -y
  sleep 6

  elasticsearchold="/var/log/elasticsearchold"
  if [ ! -d "$elasticsearchold" ]; then
    sudo mv /var/log/elasticsearch /var/log/elasticsearchold
  fi

  sudo rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch

  REPO="~/elasticsearch.repo"
  if [ -f $REPO ]; then
    rm ~/elasticsearch.repo
    sudo rm /etc/yum.repos.d/elasticsearch.repo
  fi

  touch ~/elasticsearch.repo
  echo "[elasticsearch-1.3]" >> ~/elasticsearch.repo
  echo "name=Elasticsearch repository for 1.3.x packages" >> ~/elasticsearch.repo
  echo "baseurl=http://packages.elasticsearch.org/elasticsearch/1.3/centos" >> ~/elasticsearch.repo
  echo "gpgcheck=1" >> ~/elasticsearch.repo
  echo "gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch" >> ~/elasticsearch.repo
  echo "enabled=1" >> ~/elasticsearch.repo
  sudo mv ~/elasticsearch.repo /etc/yum.repos.d/

  sudo yum install elasticsearch -y
  sleep 10
  sudo service elasticsearch start
  sleep 3
  sudo /sbin/chkconfig --add elasticsearch
  sleep 3
  sudo /usr/share/elasticsearch/bin/elasticsearch -d &
fi
  # fi
fi
curl -sX GET http://localhost:9200/
echo "Completed."
