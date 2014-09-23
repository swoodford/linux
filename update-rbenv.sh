#!/bin/bash
# This script updates RBENV and plugins, RubyGems, Bundler on a Ruby app webserver

read -r -p "Update RBENV and plugins, RubyGems, Bundler? (y/n) " INSTALL
if [[ $INSTALL =~ ^([yY][eE][sS]|[yY])$ ]]; then
	if [ -d ~/.rbenv ]; then
		cd ~/.rbenv
		git pull origin master
		cd ~/.rbenv/plugins/ruby-build
		git pull origin master
		cd ~/.rbenv/plugins/rbenv-bundler
		git pull origin master
		cd ~/.rbenv/plugins/rbenv-vars
		git pull origin master
	else
		echo "Failed to find RBENV directory, RBENV update failed."
		exit 1
	fi
	if [ -d ~/apps/production/current ]; then
		cd ~/apps/production/current
		echo "Updating RubyGems in production:"
		gem update --system
		# gem install bundler
		rbenv rehash
		echo "Gem Environment:"
		gem environment
		gem -v
		echo "Rails version:"
		rails -v
		echo "RBENV Local:"
		rbenv local
		echo "RBENV Global:"
		rbenv global
	elif [ -d ~/apps/beta/current ]; then
		cd ~/apps/beta/current
		echo "Updating RubyGems in beta:"
		gem update --system
		# gem install bundler
		rbenv rehash
		echo "Gem Environment:"
		gem environment
		gem -v
		echo "Rails version:"
		rails -v
		echo "RBENV Local:"
		rbenv local
		echo "RBENV Global:"
		rbenv global
	else
		echo "Failed to find app directory, RubyGems update failed."
		exit 1
	fi
else
	echo "Cancelled."
	exit 1
fi
