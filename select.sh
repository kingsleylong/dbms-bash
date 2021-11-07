#!/bin/bash
# Check parameters
if [ $# -lt 2 ]; then
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

# Check if columns are provided, if empty then replace with all columns (the fields used in cut command)
columns="$3"
if [ -z "$columns" ]; then
	columns="1-"
else
	query_col_count=$(echo "$columns" | grep -o ',' | wc -l)
	schema_col_count=$(echo "$schema" | cut -d',' -f"$columns" | grep -o ',' | wc -l)
	if [ $query_col_count != $schema_col_count ]; then
		echo "Error: column does not exist"
		exit 4
	fi
fi

schema=$(head -n 1 "$table")

echo "start_result"
cut -d',' -f"$columns" "$table"
echo "end_result"
