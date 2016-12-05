#!/bin/bash
# This script will setup Papertrail on an AWS EC2 server
# Assumptions: Will be setup using TCP (TLS) for transfering logs, using Nginx/PHP, username ec2-user

# Optionally configure the papertrail host and port here for automated installation of this script:
# PAPERTRAIL="YOURSUBDOMAIN.papertrailapp.com:YOURPORT"

# read -r -p "Setup Papertrail on this server? (y/n) " CONTINUE
# if [[ $CONTINUE =~ ^([yY][eE][sS]|[yY])$ ]]; then

# Check if Papertrail settings already exist in rsyslog conf to avoid duplicate settings
# if ! grep -q Papertrail /etc/rsyslog.conf; then

if [ -z "$PAPERTRAIL" ]; then
	echo "Enter your Papertrail Log Destination (Domain and Port)"
	read -r -p "Example: logs.papertrailapp.com:12345 " PAPERTRAIL
fi

PAPERTRAILHOST=$(echo $PAPERTRAIL | cut -d: -f1)
PAPERTRAILPORT=$(echo $PAPERTRAIL | cut -d: -f2)

# Install required dependency
sudo yum install rsyslog-gnutls -y

# Download Papertrail certificate
sudo curl -o /etc/papertrail-bundle.pem https://papertrailapp.com/tools/papertrail-bundle.pem

# Check MD5
md5=$(md5sum /etc/papertrail-bundle.pem | cut -d" " -f1)
if ! [ "$md5" = "ba3b40a34ec33ac0869fa5b17a0c80fc" ]; then
	echo "Invalid MD5 checksum."
	exit 1
else
	echo "MD5 checksum match!"
fi

# Backup existing rsyslog conf
# sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.bak

# Make sure rsyslog is sending with the fully-qualified domain name
if ! grep -q '$PreserveFQDN on' /etc/rsyslog.conf; then
	sudo echo '$PreserveFQDN on' >> /etc/rsyslog.conf
fi

(
cat << 'EOP'

# Begin Papertrail Settings
$PreserveFQDN on # have rsyslog send with the fully-qualified domain name
$DefaultNetstreamDriverCAFile /etc/papertrail-bundle.pem # trust these CAs
$ActionSendStreamDriver gtls # use gtls netstream driver
$ActionSendStreamDriverMode 1 # require TLS
$ActionSendStreamDriverAuthMode x509/name # authenticate by hostname
$ActionSendStreamDriverPermittedPeer *.papertrailapp.com
$ActionResumeInterval 10
$WorkDirectory /var/lib/rsyslog # where to place spool files
$ActionQueueSize 100000
$ActionQueueDiscardMark 97500
$ActionQueueHighWaterMark 80000
$ActionQueueType LinkedList
$ActionQueueFileName papertrailqueue
$ActionQueueCheckpointInterval 100
$ActionQueueMaxDiskSpace 2g
$ActionResumeRetryCount -1
$ActionQueueSaveOnShutdown on
$ActionQueueTimeoutEnqueue 10
$ActionQueueDiscardSeverity 0
EOP
) > /home/ec2-user/99-papertrail.conf
echo "*.*          @@$PAPERTRAIL" >> /home/ec2-user/99-papertrail.conf

# Get current user
# USER=$(whoami)

# Copy the Papertrail settings to the rsyslog.d config includes directory
# sudo bash -c 'cat /home/$USER/rsyslog.conf >> /etc/rsyslog.conf'
sudo bash -c 'cp /home/ec2-user/99-papertrail.conf /etc/rsyslog.d/99-papertrail.conf'

#rm /home/ec2-user/99-papertrail.conf

# else
# 	echo "Papertrail already setup on this server!  Cancelled."
# 	exit 0
# fi

if ! [ -f /usr/local/bin/remote_syslog ]; then
	# Download and Install Papertrail’s tiny standalone remote_syslog daemon
	wget -O /home/ec2-user/remote_syslog_linux_amd64.tar.gz https://github.com/papertrail/remote_syslog2/releases/download/v0.19/remote_syslog_linux_amd64.tar.gz
	tar xzf /home/ec2-user/remote_syslog_linux_amd64.tar.gz
	chown -R ec2-user:ec2-user /home/ec2-user/
	cd /home/ec2-user/remote_syslog
	sudo cp ./remote_syslog /usr/local/bin
fi

###############################################################################################
### Configure additional log files to capture
###############################################################################################

(
cat << 'EOP'
files:
  - /var/log/mysqld.log
  - /var/log/nginx/access.log
  - /var/log/nginx/error.log
  - /var/log/php-fpm/*.log
  - /var/log/php-fpm/5.6/*.log
  - /var/log/php-fpm/7.0/*.log
  - /var/log/varnish/*.log
destination:
EOP
) > /home/ec2-user/remote_syslog/log_files.yml
echo "  host: $PAPERTRAILHOST" >> /home/ec2-user/remote_syslog/log_files.yml
echo "  port: $PAPERTRAILPORT" >> /home/ec2-user/remote_syslog/log_files.yml
(
cat << 'EOP'
  protocol: tls
exclude_patterns:
  - example
EOP
) >> /home/ec2-user/remote_syslog/log_files.yml

sudo cp /home/ec2-user/remote_syslog/log_files.yml /etc/log_files.yml


###############################################################################################
### Configure remote_syslog2 to run at boot using init.d script
###############################################################################################


(
cat << 'EOP'
#!/bin/bash

### BEGIN INIT INFO
# Provides: remote_syslog
# Required-Start: $network $remote_fs $syslog
# Required-Stop: $network $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start and Stop
# Description: Runs remote_syslog
### END INIT INFO

#       /etc/init.d/remote_syslog
#
# Starts the remote_syslog daemon
#
# chkconfig: 345 90 5
# description: Runs remote_syslog
#
# processname: remote_syslog

prog="remote_syslog"
config="/etc/log_files.yml"
pid_dir="/var/run"

EXTRAOPTIONS=""

pid_file="$pid_dir/$prog.pid"

PATH=/sbin:/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH

RETVAL=0

is_running(){
  [ -e $pid_file ]
}

start(){
    echo -n $"Starting $prog: "

    unset HOME MAIL USER USERNAME
    $prog -c $config --pid-file=$pid_file $EXTRAOPTIONS
    RETVAL=$?
    echo
    return $RETVAL
}

stop(){
    echo -n $"Stopping $prog: "
    if (is_running); then
      kill `cat $pid_file`
      RETVAL=$?
      echo
      return $RETVAL
    else
      echo "$pid_file not found"
    fi
}

status(){
    echo -n $"Checking for $pid_file: "

    if (is_running); then
      echo "found"
    else
      echo "not found"
    fi
}

reload(){
    restart
}

restart(){
    stop
    start
}

condrestart(){
    is_running && restart
    return 0
}


# See how we were called.
case "$1" in
    start)
	start
	;;
    stop)
	stop
	;;
    status)
	status
	;;
    restart)
	restart
	;;
    reload)
	reload
	;;
    condrestart)
	condrestart
	;;
    *)
	echo $"Usage: $0 {start|stop|status|restart|condrestart|reload}"
	RETVAL=1
esac

exit $RETVAL

EOP
) > /home/ec2-user/remote_syslog.init.d

chmod +x /home/ec2-user/remote_syslog.init.d
sudo mv /home/ec2-user/remote_syslog.init.d /etc/init.d/remote_syslog
if [ ! -f /etc/rc3.d/S30remote_syslog ]; then
	sudo ln -s /etc/init.d/remote_syslog /etc/rc3.d/S30remote_syslog
fi


sudo killall -HUP rsyslog rsyslogd
service remote_syslog start
sudo /etc/init.d/rsyslog restart
sudo service rsyslog restart

echo "Papertrail Setup Completed."

# 	else
# 		echo "Cancelled."
# 		exit 1
# fi
