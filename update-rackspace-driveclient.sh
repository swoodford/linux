#!/bin/bash

# Script to update Rackspace Driveclient Cloud Backup Agent on Ubuntu
# http://www.rackspace.com/knowledge_center/article/update-the-rackspace-cloud-backup-agent

exec &>> updateDriveClient.log

sudo pkill driveclient
sudo sh -c 'wget -q "http://agentrepo.drivesrvr.com/debian/agentrepo.key" -O- | apt-key add -'
sudo apt-get update; sudo apt-get install driveclient
sudo service driveclient start
