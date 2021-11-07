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
if [ ! -e "$table" ]; then
	echo "Error: table does not exist"
	exit 3
fi

# Check if tuple columns match table schema 
tuple="$3"

header=$(head -n 1 "$table")
table_cols=$(echo "$header" | grep -o ',' | wc -l)
tuple_cols=$(echo "$tuple" | grep -o ',' | wc -l)

if [ $table_cols = $tuple_cols ]; then
	echo "$tuple" >> "$table"
	echo "OK: tuple inserted"
	exit 0
else
	echo "Error: number of columns in tuple does not match schema"
	exit 4
fi
