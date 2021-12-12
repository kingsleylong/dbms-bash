#!/bin/bash

# Check parameters
if [ $# -eq 0 ]; then
	echo "Error: no paramter"
	exit 1
elif [ $# -gt 1 ]; then
	echo "Error: too many parameters"
	exit 1
fi

database="$1"
./P.sh $database
if [ -e "$database" ]; then
	echo "Error: DB already exists"
	./V.sh "$database"
	exit 2
else
	mkdir "$database"
	echo "OK: database created"
	./V.sh "$database"
	exit 0
fi
