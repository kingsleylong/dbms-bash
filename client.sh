#!/bin/bash

# reference of how to write a Bash function https://linuxize.com/post/bash-functions/
# check if the server is running, if not then exit
check_server() {
	if [ ! -e "$server_pipe" ]; then
  	        echo "Error: server is not running."
		safe_exit 2
	fi
}

# a safe way to exit the client with cleaning done
safe_exit() {
	exitcode=$1
	# remove the client pipe before exit
	if [ -e "$client_pipe" ]; then
                rm "$client_pipe"
	fi
	exit $exitcode
}

# gracefully exit client
# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
	safe_exit 99
}

function create_client_pipe() {
	client_id="$1"
	client_pipe="${client_id}.pipe"
	if [ ! -e "$client_pipe" ]; then
		mkfifo "$client_pipe"
	else
		echo "Error: a client with id ${client_id} is already running. Exit now."
		exit 3
	fi
}

# Check parameters
if [ $# -eq 0 ]; then
	echo "Error: no paramter"
	exit 1
elif [ $# -gt 1 ]; then
	echo "Error: too many parameters"
	exit 1
fi

server_pipe="server.pipe"
check_server

client_id="$1"
create_client_pipe "$client_id"

while true; do
	# read command into an array
	read -a command_arr
	arg_cnt=${#command_arr[@]}
	
	# parameters check
	if [ $arg_cnt -lt 1 ]; then
		echo "Error: bad request"
		continue
	fi
	# get the first parameter as req
	req_command=${command_arr[0]}
	if [ ! $req_command ]; then
		echo "Error: bad command"
		continue
	fi
	# remove the first element which is the command, so the rest of array would be parameters
	unset 'command_arr[0]'

	# echo "[DEBUG] command: "${command_arr[@]}", command count:${#command_arr[@]}"
	# support exit command in the client
	case "${req_command}" in
		exit)
			safe_exit 0
			;;
	esac
	message="${req_command} $client_id ${command_arr[@]}"
	check_server
	# echo "[DEBUG] message: $message"
	echo "$message" > "$server_pipe"

	# Read response from server pipe
	while read response; do
		echo "$response";
		# if the server confirms shutdown, then exit the client too.
		if [ "$response" = "OK: shutting down server.." ]; then
			echo "Exit client now."
			safe_exit 0
		fi
	done < "$client_pipe"
done
