#!/bin/bash

# Check parameters
if [ $# -lt 3 ]; then
	echo "Error: parameters problem"
	exit 1
elif [ $# -gt 3 ]; then
	echo "Error: too many parameters"
	exit 1
fi

base=$(pwd)

# Check if database exists
database="$1"

# try to increment semaphore
./P.sh $database
# got semaphore, enter critical section
if [ ! -e "$database" ]; then
	echo "Error: DB does not exist"
	./V.sh $database
	exit 2
fi

# Check if table exists
table="$2"
if [ -e "$database/$table" ]; then
	echo "Error: table already exists"
	./V.sh $database
	exit 3
fi

# Create table
columns="$3"
echo "$columns" > "$database/$table"
echo "OK: table created"
# decrement semaphore
./V.sh $database
exit 0

