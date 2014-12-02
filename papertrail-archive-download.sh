# Download your Papertrail Log Archives from current day through past n days prior

echo "Download Papertrail Archive"
read -r -p "How many days to download? " DAYS
read -r -p "Enter your Papertrail API Token: " TOKEN

DAYS=$(($DAYS+1))

seq 0 $DAYS | xargs -I {} date -u --date='{} day ago' +%Y-%m-%d | \
xargs -I {} curl --progress-bar -f --no-include -o {}.tsv.gz \
-L -H "X-Papertrail-Token: $TOKEN" https://papertrailapp.com/api/v1/archives/{}/download
