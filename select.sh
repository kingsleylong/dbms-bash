#!/bin/bash
# Check parameters
if [ $# -le 1 ]; then
	echo "Error: paramters problem"
	exit 1
elif [ $# -gt 3 ]; then
        echo "Error: too many parameters"
        exit 1
fi

base=$(pwd)
database="$1"

# try to increment semaphore
./P.sh $database
# semaphore increamented, enter critical section
# Check if database exists
if [ ! -e "$database" ]; then
	echo "Error: DB does not exist"
	./V.sh $database
	exit 2
fi

# Check if table exists
table="$2"
if [ ! -e "$database/$table" ]; then
	echo "Error: table does not exist"
	./V.sh $database
	exit 3
fi

# Check if columns are provided, if empty then replace with all columns (the fields used in cut command)
columns="$3"
schema=$(head -n 1 "$database/$table")
if [ -z "$columns" ]; then
	columns="1-"
else
	# split the sepecified column numbers to an array
	columns_list=($(echo "$columns" | cut -d',' -f1- --output-delimiter=" "))
	# for each column number in the array, test if the corresponding column exists in the schema
	for col in ${columns_list[@]}; do
		col_check=$(echo "$schema" | cut -d',' -f$col 2> /dev/null | wc -w)
		if [ $(( col_check )) -eq 0 ]; then
			echo "Error: column does not exist"
			./V.sh $database
			exit 4
		fi
	done
fi

echo 'start_result'
cut -d',' -f"$columns" "$database/$table"
echo 'end_result'
./V.sh $database
exit 0
