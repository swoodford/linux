#!/bin/bash
# This script will disable internal mail routing on a server, required if mail is being sent to the same domain as the server's hostname

function editsendmail(){
	sudo touch /root/editsendmail
	sudo echo -e "define(\`MAIL_HUB', \`$SETHOSTNAME.')dnl" >> /root/editsendmail
	sudo echo -e "define(\`LOCAL_RELAY', \`$SETHOSTNAME.')dnl" >> /root/editsendmail
}

# First verify this has not already been done
if ! grep -q LOCAL_RELAY /etc/mail/sendmail.mc; then

	# Set the desired domain trying to detect automatically
	DOMAIN=$(hostname | cut -d "." -f2,3)
	echo "Domain =" $DOMAIN
	read -r -p "Use this Domain? (y/n) " CONTINUE

	if [[ $CONTINUE =~ ^([yY][eE][sS]|[yY])$ ]]; then
		SETHOSTNAME=$DOMAIN
	else
		echo "Domain =" $HOSTNAME
		read -r -p "Use this Domain? (y/n) " CONTINUE2

		if [[ $CONTINUE2 =~ ^([yY][eE][sS]|[yY])$ ]]; then
			SETHOSTNAME=$HOSTNAME
		else
			read -r -p "Type Domain: " SETHOSTNAME

			if [[ -z $SETHOSTNAME ]]; then
				echo "Failed to set Domain!"
				exit 1
			fi
		fi
	fi
	# Call the function
	editsendmail

	# Append to the sendmail config with the hostname and new definitions
	sudo bash -c 'cat /root/editsendmail >> /etc/mail/sendmail.mc'

	sudo rm /root/editsendmail

	# Install required dependency
	sudo yum install sendmail-cf -y

	# Recompile sendmail with new config
	sudo /etc/mail/make

	sudo service sendmail restart

	echo "Completed."

else
	echo "Internal mail routing already disabled."
	exit 1
fi
