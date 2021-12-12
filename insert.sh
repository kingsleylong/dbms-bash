#!/bin/bash
# Check parameters
if [ $# -lt 3 ]; then
	echo "Error: paramters problem"
	exit 1
elif [ $# -gt 3 ]; then
        echo "Error: too many parameters"
        exit 1
fi

base="$(pwd)"

# Check if database exists
database="$1"

# try to increment semaphore
./P.sh $database
# got semaphore, enter critical section
if [ ! -e "$database" ]; then
	echo "Error: DB does not exist"
	./V.sh "$database"
	exit 2
fi

# Check if table exists
table="$2"
if [ ! -e "$database/$table" ]; then
	echo "Error: table does not exist"
	./V.sh "$database"
	exit 3
fi

# Check if tuple columns match table schema 
tuple="$3"

header=$(head -n 1 "$database/$table")
table_cols=$(echo "$header" | grep -o ',' | wc -l)
tuple_cols=$(echo "$tuple" | grep -o ',' | wc -l)

if [ $table_cols = $tuple_cols ]; then
	echo "$tuple" >> "$database/$table"
	echo "OK: tuple inserted"
	./V.sh "$database"
	exit 0
else
	echo "Error: number of columns in tuple does not match schema"
	./V.sh "$database"
	exit 4
fi
