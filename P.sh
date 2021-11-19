#! /bin/bash
# This script is to used to increment a semaphore, which is the link to the current script
if [ -z "$1" ]; then
	echo "Usage $0 database-name"
	exit 1
else
	# remove the trailing / in case a directory name is passed in
	database=${1%/}
	# use the current script as the link target
	while ! ln "$0" "$database.lock" 2>/dev/null; do
		sleep 1
	done
	exit 0
fi
