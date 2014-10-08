#!/bin/bash
# This script downloads s3cmd from the git repo, installs and starts setup

# Test if already installed
command -v s3cmd >/dev/null 2>&1 || {
	cd ~;
	git clone git@github.com:s3tools/s3cmd.git;
	cd s3cmd;
	sudo python setup.py install;
	s3cmd --configure;
}

echo " "
echo "s3cmd installed"