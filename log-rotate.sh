#!/bin/bash
# This script will rotate system logs, web server logs, and app logs for each environment (staging/beta/production)

# Set date as variable
DATE=$(date '+%Y%m%d')

function syslog(){

	echo "Beginning System Log Archiving"

	cd /var/log

	if ! [ -d /var/log/archive ]; then
		echo "Creating System Log Archive Directory"
		sudo mkdir /var/log/archive
	fi

	sudo gzip *2014* 2> /dev/null
	sudo mv *.gz archive 2> /dev/null

	if [ -d /var/log/nginx ]; then

		echo "Beginning Nginx Log Archiving"

		sudo bash -c 'if ! [ -d /var/log/nginx/archive ]; then
			echo "Creating Nginx Log Archive Directory"
			sudo mkdir /var/log/nginx/archive
		fi' 2> /dev/null

		sudo bash -c 'cd /var/log/nginx && mv *.gz /var/log/nginx/archive' 2> /dev/null
	fi

	if [ -d /var/log/httpd ]; then

		echo "Beginning Apache Log Archiving"

		sudo bash -c 'if ! [ -d /var/log/httpd/archive ]; then
			echo "Creating Apache Log Archive Directory"
			sudo mkdir /var/log/httpd/archive
		fi' 2> /dev/null

		sudo bash -c 'cd /var/log/httpd && gzip *2014* && mv *.gz archive' 2> /dev/null

	fi

	echo "System Log Archiving Completed."
}

function applog(){
	echo "Beginning App Log Rotation and Archiving"

	# Check environment and set as variable
	if [ -d ~/apps/production/current ]; then
		ENVIRONMENT=production

	elif [ -d ~/apps/beta/current ]; then
		ENVIRONMENT=beta

	elif [ -d ~/apps/staging/current ]; then
		ENVIRONMENT=staging

	else
		echo "Failed to find any app directory, Log Rotation failed."
		exit 1
	fi

	echo "Detected Environment: $ENVIRONMENT"

	cd ~/apps/$ENVIRONMENT/current/log

	if ! [ -d ~/apps/$ENVIRONMENT/current/log/archive ]; then
		echo "Creating App Log Archive Directory"
		mkdir ~/apps/$ENVIRONMENT/current/log/archive
	fi

	echo "Stopping Unicorn"
	bundle exec rake unicorn:stop
	echo "Stopping New Relic"
	sudo service newrelic-sysmond stop

	if [ -f ~/apps/$ENVIRONMENT/current/log/unicorn.log ]; then
		mv unicorn.log unicorn$DATE.log
		gzip unicorn$DATE.log
		mv unicorn$DATE.log.gz archive/
	fi

	if [ -f ~/apps/$ENVIRONMENT/current/log/sellect.log ]; then
		mv sellect.log sellect$DATE.log
		gzip sellect$DATE.log
		mv sellect$DATE.log.gz archive/
	fi

	if [ -f ~/apps/$ENVIRONMENT/current/log/$ENVIRONMENT.log ]; then
		mv $ENVIRONMENT.log $ENVIRONMENT$DATE.log
		gzip $ENVIRONMENT$DATE.log
		mv $ENVIRONMENT$DATE.log.gz archive/
	fi

	if [ -f ~/apps/$ENVIRONMENT/current/log/newrelic_agent.log ]; then
		mv newrelic_agent.log newrelic_agent$DATE.log
		gzip newrelic_agent$DATE.log
		mv newrelic_agent$DATE.log.gz archive/
	fi

	if [ -f ~/apps/$ENVIRONMENT/current/log/sidekiq.log ]; then
		SQ=1
		echo "Stopping Sidekiq"
		sidekiqctl stop ~/apps/$ENVIRONMENT/shared/sidekiq.pid 30
		mv sidekiq.log sidekiq$DATE.log
		gzip sidekiq$DATE.log
		mv sidekiq$DATE.log.gz archive/
	fi

	echo "Starting Unicorn"
	bundle exec rake unicorn:start

	if [[ $SQ = 1 ]]; then
		echo "Restarting Sidekiq"
		bundle exec rake sidekiq:restart
	fi

	echo "Starting New Relic"
	sudo service newrelic-sysmond start

	echo "App Log Rotation and Archiving Completed."
}

read -rp "Archive System Logs? (y/n) " CONTINUE
if [[ $CONTINUE =~ ^([yY][eE][sS]|[yY])$ ]]; then
	syslog
fi

read -rp "Rotate and Archive App Logs? (y/n) " CONTINUE
if [[ $CONTINUE =~ ^([yY][eE][sS]|[yY])$ ]]; then
	applog
fi

echo "Completed."
