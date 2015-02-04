linux
=======

A collection of shell scripts meant to be run in Linux for automating various tasks

[![Build Status](https://travis-ci.org/swoodford/linux.svg?branch=master)](https://travis-ci.org/swoodford/linux)

- **dnsimple-dns-record-updater.sh** Determine the current local dynamic IP address then update the A record using DNSimple API
- **dnsimple-export-zones.sh** Export the zone file for each domain in a DNSimple account
- **elasticsearch-java-update.sh** Install or update Java and Elasticsearch to the latest versions
- **elasticsearch-restart.sh** Stop/start Java & Elasticsearch
- **ffmpeg-compiler.sh** Compile ffmpeg and components from source
- **install-newrelic-agent.sh** Install New Relic monitoring agent on a server
- **install-redis-cli.sh** Install the Redis CLI
- **install-s3cmd.sh** Install and setup s3cmd from the GitHub Repo
- **log-rotate.sh** Rotate system logs, web server logs, and app logs for each environment
- **mysql-backup-local-to-s3.sh** Dump a MySQL database, gzip it then upload to AWS S3
- **papertrail-archive-download.sh** Download your Papertrail Log Archives from current day through past n days prior
- **sendmail-disable-internal-routing.sh** Disable internal sendmail routing
- **sendmail-auth.sh** Resolve the X-Authentication-Warning header in emails sent via sendmail
- **setup-papertrail.sh** Setup Papertrail for each environment on server
- **shellshock-test.sh** Test Bash and ZSH for shellshock vulnerability
- **update-rackspace-driveclient.sh** Update Rackspace Driveclient Cloud Backup Agent on Ubuntu
- **update-rbenv.sh** Update RBENV and plugins, RubyGems, Bundler on a Ruby app webserver