#!/bin/bash

# This script will stop/start Java & Elasticsearch

sudo service elasticsearch status
sudo service elasticsearch stop
sudo kill java
sudo service elasticsearch start
sudo /usr/share/elasticsearch/bin/elasticsearch -d &
curl -sX GET http://localhost:9200/
