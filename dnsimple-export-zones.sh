#!/bin/bash
# This script will export the zone file for each domain in a DNSimple account to the zones folder
# Requires Python

# Set date as variable
# DATE=$(date '+%Y%m%d')

EMAIL="YOUR DNSIMPLE ACCOUNT EMAIL"
TOKEN="YOUR DNSIMPLE ACCOUNT API TOKEN"

if ! [ -d zones/ ]; then
	mkdir zones
fi

# Get list of domains in DNSimple account
function domainlist(){
	curl  -H "Accept: application/json" \
	      -H "X-DNSimple-Token: $EMAIL:$TOKEN" \
	      https://api.dnsimple.com/v1/domains \
	      -sS | python -m json.tool | grep -w name | cut -d '"' -f4
}

# Export the zone file for each domain found
function zoneexport(){
	curl  -H "Accept: text/plain" \
	      -H "X-DNSimple-Token: $EMAIL:$TOKEN" \
	      https://api.dnsimple.com/v1/domains/$DOMAIN_ID/zone \
	      -o zones/$DOMAIN_ID \
	      -sS
}

DOMAINLIST=domainlist

# Count domains found
TOTALDOMAINS=$("$DOMAINLIST" | wc -l)

echo " "
echo "========================================="
echo "Exporting Zone Files for DNSimple Domains"
echo "Total number of domains: "$TOTALDOMAINS
echo "========================================="
echo " "

START=1
for (( COUNT=$START; COUNT<=$TOTALDOMAINS; COUNT++ ))
do
	echo "========================================="
	echo \#$COUNT
	DOMAIN_ID=$("$DOMAINLIST" | nl | grep -w $COUNT | cut -f 2)
	zoneexport
	echo "Exported: "$DOMAIN_ID
done

echo "========================================="
echo " "
echo "Completed!"
echo " "
