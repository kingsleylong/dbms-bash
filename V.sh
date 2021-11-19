#! /bin/bash
# This script is to used to decrement a semaphore, which is the link to the current script
if [ -z "$1" ]; then
        echo "Usage $0 database-name"
	exit 1
else
	# remove the trailing / in case a directory name is passed in
        database=${1%/}
	rm "$database.lock"
        exit 0
fi
