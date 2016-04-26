#!/bin/bash
# This script will setup Papertrail for each environment (staging/beta/production)
# Assumptions: Will be setup using TCP (TLS) for transfering logs, using Unicorn and Sidekiq in a Ruby app

read -r -p "Setup Papertrail on this server? (y/n) " CONTINUE
if [[ $CONTINUE =~ ^([yY][eE][sS]|[yY])$ ]]; then

	# Check if Papertrail settings already exist in rsyslog conf to avoid duplicate settings
	if ! grep -q Papertrail /etc/rsyslog.conf; then

		read -r -p "Enter your Papertrail Log Destination (Domain and Port) " PAPERTRAIL

		# Install required dependency
		sudo yum install rsyslog-gnutls -y

		# Download Papertrail certificate
		# sudo wget -O /etc/syslog.papertrail.crt https://papertrailapp.com/tools/syslog.papertrail.crt
		sudo curl -o /etc/papertrail-bundle.pem https://papertrailapp.com/tools/papertrail-bundle.pem

		# Check MD5
		md5=$(md5sum /etc/papertrail-bundle.pem | cut -d" " -f1)
		if ! [ "$md5" = "c75ce425e553e416bde4e412439e3d09" ]; then
			echo "Invalid MD5 checksum."
			exit 1
		else
			echo "MD5 checksum match!"
		fi
	

		# Backup existing rsyslog conf
		sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.bak

		# Append Papertrail settings to rsyslog conf
		touch ~/rsyslog.conf

		echo $'\n' >> ~/rsyslog.conf
		echo "# Begin Papertrail Settings" >> ~/rsyslog.conf
		echo "\$PreserveFQDN on" >> ~/rsyslog.conf
		echo "\$DefaultNetstreamDriverCAFile /etc/papertrail-bundle.pem # trust these CAs" >> ~/rsyslog.conf
		echo "\$ActionSendStreamDriver gtls # use gtls netstream driver" >> ~/rsyslog.conf
		echo "\$ActionSendStreamDriverMode 1 # require TLS" >> ~/rsyslog.conf
		echo "\$ActionSendStreamDriverAuthMode x509/name # authenticate by hostname" >> ~/rsyslog.conf
		echo "\$ActionSendStreamDriverPermittedPeer *.papertrailapp.com" >> ~/rsyslog.conf
		echo "\$ActionResumeInterval 10" >> ~/rsyslog.conf
		echo "\$WorkDirectory /var/lib/rsyslog # where to place spool files" >> ~/rsyslog.conf
		echo "\$ActionQueueSize 100000" >> ~/rsyslog.conf
		echo "\$ActionQueueDiscardMark 97500" >> ~/rsyslog.conf
		echo "\$ActionQueueHighWaterMark 80000" >> ~/rsyslog.conf
		echo "\$ActionQueueType LinkedList" >> ~/rsyslog.conf
		echo "\$ActionQueueFileName papertrailqueue" >> ~/rsyslog.conf
		echo "\$ActionQueueCheckpointInterval 100" >> ~/rsyslog.conf
		echo "\$ActionQueueMaxDiskSpace 2g" >> ~/rsyslog.conf
		echo "\$ActionResumeRetryCount -1" >> ~/rsyslog.conf
		echo "\$ActionQueueSaveOnShutdown on" >> ~/rsyslog.conf
		echo "\$ActionQueueTimeoutEnqueue 10" >> ~/rsyslog.conf
		echo "\$ActionQueueDiscardSeverity 0" >> ~/rsyslog.conf
		echo "*.*          @@$PAPERTRAIL" >> ~/rsyslog.conf

		# Get current user
		USER=$(whoami)

		# Append the Papertrail settings to the rsyslog config
		sudo bash -c 'cat /home/$USER/rsyslog.conf >> /etc/rsyslog.conf'

		rm ~/rsyslog.conf

	else
		echo "Papertrail already setup on this server!  Cancelled."
		exit 1
	fi

	# Check environment and set as variable
	# if [ -d ~/apps/production/current ]; then
	# 	ENVIRONMENT=production

	# elif [ -d ~/apps/beta/current ]; then
	# 	ENVIRONMENT=beta

	# elif [ -d ~/apps/staging/current ]; then
	# 	ENVIRONMENT=staging

	# else
	# 	echo "Failed to find any app directory, Papertrail Setup failed."
	# 	exit 1
	# fi

		# Backup existing Papertrail conf
		if [ -f /etc/rsyslog.d/90-papertrail.conf ]; then
			sudo cp /etc/rsyslog.d/90-papertrail.conf /etc/rsyslog.d/90-papertrail.conf.bak
		fi

		# Add Papertrail settings for this server
		# touch ~/90-papertrail.conf

		# echo "\$ModLoad imfile" >> ~/90-papertrail.conf
		# echo $'\n' >> ~/90-papertrail.conf
		# echo "# for each local log file path, duplicate the 6 lines below and edit lines 2-4" >> ~/90-papertrail.conf
		# echo "\$RuleSet papertrail  # use a non-default ruleset (keeps logs out of /var/log/)" >> ~/90-papertrail.conf
		# echo "\$InputFileName /home/deploy/apps/$ENVIRONMENT/current/log/$ENVIRONMENT.log" >> ~/90-papertrail.conf
		# echo "\$InputFileTag $ENVIRONMENT.log:" >> ~/90-papertrail.conf
		# echo "\$InputFileStateFile /var/log/papertrail-$ENVIRONMENT.log" >> ~/90-papertrail.conf
		# echo "\$InputFilePersistStateInterval 100 # update state file every 100 lines" >> ~/90-papertrail.conf
		# echo "\$InputRunFileMonitor" >> ~/90-papertrail.conf
		# echo $'\n' >> ~/90-papertrail.conf
		# echo "\$RuleSet papertrail  # use a non-default ruleset (keeps logs out of /var/log/)" >> ~/90-papertrail.conf
		# echo "\$InputFileName /home/deploy/apps/$ENVIRONMENT/current/log/unicorn.log" >> ~/90-papertrail.conf
		# echo "\$InputFileTag unicorn.log:" >> ~/90-papertrail.conf
		# echo "\$InputFileStateFile /var/log/papertrail-unicorn.log" >> ~/90-papertrail.conf
		# echo "\$InputFilePersistStateInterval 100 # update state file every 100 lines" >> ~/90-papertrail.conf
		# echo "\$InputRunFileMonitor" >> ~/90-papertrail.conf
		# echo $'\n' >> ~/90-papertrail.conf
		# echo "\$RuleSet papertrail  # use a non-default ruleset (keeps logs out of /var/log/)" >> ~/90-papertrail.conf
		# echo "\$InputFileName /home/deploy/apps/$ENVIRONMENT/current/log/sidekiq.log" >> ~/90-papertrail.conf
		# echo "\$InputFileTag sidekiq.log:" >> ~/90-papertrail.conf
		# echo "\$InputFileStateFile /var/log/papertrail-sidekiq.log" >> ~/90-papertrail.conf
		# echo "\$InputFilePersistStateInterval 100 # update state file every 100 lines" >> ~/90-papertrail.conf
		# echo "\$InputRunFileMonitor" >> ~/90-papertrail.conf
		# echo $'\n' >> ~/90-papertrail.conf
		# echo "# destination (see https://papertrailapp.com/systems/setup)" >> ~/90-papertrail.conf
		# echo "*.* @@$PAPERTRAIL" >> ~/90-papertrail.conf
		# echo "# for clarity, explicitly discard everything (this is typically not necessary) *.* ~" >> ~/90-papertrail.conf
		# echo $'\n' >> ~/90-papertrail.conf
		# echo "# all done. change to default ruleset (RSYSLOG_DefaultRuleset) for any following config" >> ~/90-papertrail.conf
		# echo "\$RuleSet RSYSLOG_DefaultRuleset" >> ~/90-papertrail.conf
		# echo $'\n' >> ~/90-papertrail.conf

		# sudo mv ~/90-papertrail.conf /etc/rsyslog.d/

		sudo killall -HUP rsyslog rsyslogd
		sudo /etc/init.d/rsyslog restart

		echo "Papertrail Setup Completed."

	else
		echo "Cancelled."
		exit 1
fi
