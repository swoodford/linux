linux
=======

A collection of shell scripts meant to be run in Linux for performing various tasks

- **disable-internal-mail-routing.sh** disable internal mail routing on a server, required if mail is being sent to the same domain as the server's hostname
- **dnsimple-dns-record-updater.sh** Determine the current local dynamic IP address then update the A record using DNSimple API
- **elasticsearch-java-update.sh** Install or update Java and Elasticsearch to the latest versions
- **elasticsearch-restart.sh** Stop/start Java & Elasticsearch
- **ffmpeg-compiler.sh** Compile ffmpeg and components from source
- **install-newrelic-agent.sh** Install New Relic monitoring agent on a server
- **install-redis-cli.sh** Install the Redis CLI
- **install-s3cmd.sh** Install and setup s3cmd from the GitHub Repo
- **log-rotate.sh** Rotate system logs, web server logs, and app logs for each environment
- **mysql-backup-local-to-s3.sh** Dump a MySQL database, gzip it then upload to AWS S3
- **papertrail-archive-download.sh** Download your Papertrail Log Archives from current day through past n days prior
- **setup-papertrail.sh** Setup Papertrail for each environment on server
- **shellshock-test.sh** Test Bash and ZSH for shellshock vulnerability
- **update-rackspace-driveclient.sh** Update Rackspace Driveclient Cloud Backup Agent on Ubuntu
- **update-rbenv.sh** Update RBENV and plugins, RubyGems, Bundler on a Ruby app webserver