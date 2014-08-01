#!/bin/sh
# This script will determine the current local dynamic IP address then update the A record with the current IP address for YOUR DOMAIN.COM hosted at DNSimple
# It can be scheduled as a task or cronjob and run daily or weekly to keep the A record updated with the current dynamic IP address

exec >> /var/log/DNSimpleARecordUpdater.log

TOKEN="YOUR API TOKEN HERE"
DOMAIN_ID="YOUR DOMAIN.COM"
RECORD_ID="DNSIMPLE RECORD ID"
IP=$(curl -s http://icanhazip.com/)
# need to do some error checking here for unexpected curl results or a timeout or other error
 
curl -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "X-DNSimple-Domain-Token: $TOKEN" \
     -X "PUT" \
     -ski "https://api.dnsimple.com/v1/domains/$DOMAIN_ID/records/$RECORD_ID" \
     -d "{\"record\":{\"content\":\"$IP\"}}"
     # need to do some error checking here for unexpected curl results or a timeout or other error
     # possibly generate an alert or email notification for any failures
