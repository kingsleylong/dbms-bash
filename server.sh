#!/bin/bash

cleanup() {
	if [ -e "$server_pipe" ]; then
  	      rm "$server_pipe"
	fi
}

# gracefully exit server
# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        if [ -e "$server_pipe" ]; then
                cleanup
                exit 0
        else
                exit 99
        fi
}
server_pipe="server.pipe"
if [ ! -e "$server_pipe" ]; then
	mkfifo "$server_pipe"
fi
while true; do
	# read commands into an array
	read -a command_arr < "$server_pipe"
	#echo "[DEBUG] command: ${command_arr[@]}, arg count: ${#command_arr[@]}"
	# get the first
	req_command=${command_arr[0]}
	client_id="${command_arr[1]}"
	client_pipe="${client_id}.pipe"
	# remove the first element which is the command, so the rest of array would be parameters
	# for this command which we could simply pass into the script later
	unset 'command_arr[0]'
	unset 'command_arr[1]'
	# echo "[DEBUG] req: ${req_command}, arguments: "${command_arr[@]}
	case "${req_command}" in
		create_database)
			./create_database.sh "${command_arr[@]}" > "$client_pipe" &
			;;
		create_table)
			./create_table.sh "${command_arr[@]}" > "$client_pipe" &
			;;
		insert)
			./insert.sh "${command_arr[@]}" > "$client_pipe" &
			;; 
		select)
			#echo "[DEBUG] response select to $client_pipe"
			./select.sh "${command_arr[@]}" > "$client_pipe" &
			#echo '[DEBUG] select done'
			;; 
		shutdown)
			#echo "[DEBUG] Say good by to $client_pipe"
			# delete server pipe before shutdown
			echo "OK: shutting down server.." > "$client_pipe"
			cleanup
			exit 0
			;;
	 	*)
			#echo "[DEBUG]: bad request"
			echo "Error: bad request" > "$client_pipe"
			continue
	esac
done
