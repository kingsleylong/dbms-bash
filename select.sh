#!/bin/bash
# Check parameters
if [ $# -le 1 ]; then
	echo "Error: paramters problem"
	exit 1
elif [ $# -gt 3 ]; then
        echo "Error: too many parameters"
        exit 1
fi

base="$(pwd)"
database="$1"

# try to increment semaphore
./P.sh "$database"
# semaphore increamented, enter critical section
# Check if database exists
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

# Check if columns are provided, if empty then replace with all columns (the fields used in cut command)
columns="$3"
schema=$(head -n 1 "$database/$table")
select_column_idx=()
if [ -z "$columns" ]; then
	columns="${schema}"
fi
	# split the sepecified column names to an array
	select_columns=($(echo "$columns" | cut -d',' -f1- --output-delimiter=" "))
	#echo "[DEBUG]select columns: ${select_columns[@]}, size:${#select_columns[@]}"
	schema_columns=($(echo "$schema" | cut -d',' -f1- --output-delimiter=" "))
	#echo "[DEBUG]schema columns: ${schema_columns[@]}, size:${#schema_columns[@]}"
	# for each column name in the array, test if it exists in the schema
	for col in ${select_columns[@]}; do
		valid=false
		for (( i=0; i<${#schema_columns[@]}; i++ )); do
		#for scol in ${schema_columns[@]}; do
			scol=${schema_columns[$i]}
			#echo "[DEBUG]col=$col, scol=$scol"
			if [ "${col}" = "${scol}" ]; then
			#	echo "[DEBUG]equal: col=$col, scol=$scol"
				valid=true
				select_column_idx+=($i)
				break
			fi
		done
		if [ $valid = false ]; then
			echo "Error: column ${col} does not exist"
			./V.sh "$database"
			exit 4
		fi
	done

#echo "[DEBUG]select_column_idx: ${select_column_idx[@]}"
echo 'start_result'
while read row; do
	#echo "[DEBUG]row: $row"
	select_col_cnt=${#select_column_idx[@]}
	for (( i=0; i<${select_col_cnt}; i++ )); do
		echo -n $row | cut -d',' -f"$(( ${select_column_idx[$i]} + 1 ))" -z
		if [ $i -lt $(( $select_col_cnt - 1 )) ]; then
			echo -n ","
		else
			echo ""
		fi
	done
done < "$database/$table"
echo 'end_result'
./V.sh "$database"
exit 0
