#!/bin/bash

# Check parameters
if [ $# -eq 0 ]; then
	echo "Error: no paramter"
	exit 1
fi

database="$1"
if [ -e "$database" ]; then
	echo "Error: DB${database} already exists"
fi
