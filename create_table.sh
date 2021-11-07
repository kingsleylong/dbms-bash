#!/bin/bash

# Check parameters
if [ $# -lt 3 ]; then
	echo "Error: paramters problem"
	exit 1
fi

# Check if database exists
database="$1"
if [ ! -e "$database" ]; then
	echo "Error: DB does not exist"
	exit 2
fi

# Go to database
cd "$database"

# Check if table exists
table="$2"
if [ -e "$table" ]; then
	echo "Error: table already exists"
	exit 3
fi

# Create table
columns="$3"
echo "$columns" > "$table"
echo "OK: table created"
exit 0

