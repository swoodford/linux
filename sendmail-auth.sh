#!/bin/bash
# This script will resolve the X-Authentication-Warning header in emails sent via sendmail

# Get current user
USER=$(whoami)

# First verify this has not already been done
if ! grep -q $USER /etc/mail/trusted-users; then

	read -r -p "Proceed to resolve the sendmail X-Authentication-Warning? (y/n) " CONTINUE

	if [[ $CONTINUE =~ ^([yY][eE][sS]|[yY])$ ]]; then

		# Append to the sendmail trusted users config with the deploy username
		sudo bash -c 'echo $USER >> /etc/mail/trusted-users'

		# Append to the sendmail submit config
		touch ~/editsendmail
		echo -e "define(\`_USE_CT_FILE_',\`1')dnl" >> ~/editsendmail
		echo -e "define(\`confCT_FILE',\`/etc/mail/trusted-users')dnl" >> ~/editsendmail

		sudo bash -c 'cat /home/deploy/editsendmail >> /etc/mail/submit.mc'

		rm ~/editsendmail

		# Install required dependency
		sudo yum install sendmail-cf -y

		# Recompile sendmail with new config
		sudo /etc/mail/make

		sudo service sendmail restart

		echo "Completed."

	else
		echo "Cancelled."
		exit 1
	fi

else
	echo "X-Authentication-Warning already resolved."
	exit 1
fi
