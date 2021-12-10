#!/bin/bash

cleanup() {
	if [ -e $client_pipe ]; then
                rm $client_pipe
	fi
}

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
	if [ -e $client_pipe ]; then
		cleanup
		exit 0
	else
		exit 99
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
if [ ! -e "$server_pipe" ]; then
	echo "Error: server is not running."
	exit 2
fi 

client_id=$1
client_pipe="${client_id}.pipe"
if [ ! -e $client_pipe ]; then
	mkfifo $client_pipe
else
	echo "Error: client with id ${client_id} is already running."
	exit 3
fi
while true; do
	# read command into an array
	read -a command_arr
	# get the first parameter
	req_command=${command_arr[0]}
	# remove the first element which is the command, so the rest of array would be parameters
	unset 'command_arr[0]'
	argcnt=$(( ${#command_arr[@]} ))
	case "${req_command}" in
		create_database)
			if [ $argcnt -eq 0 ]; then
			        echo "Error: no paramter"
				continue
			elif [ $argcnt -gt 1 ]; then
       				echo "Error: too many parameters"
				continue
			fi
			;;
		create_table)
			if [ $argcnt -lt 3 ]; then
				echo "Error: parameters problem"
				continue
			elif [ $argcnt -gt 3 ]; then
				echo "Error: too many parameters"
				continue
			fi
			;;
		insert)
			if [ $argcnt -lt 3 ]; then
				echo "Error: paramters problem"
				continue
			elif [ $argcnt -gt 3 ]; then
        			echo "Error: too many parameters"
				continue
			fi
			;; 
		select)
			if [ $argcnt -le 1 ]; then
				echo "Error: paramters problem"
				continue
			elif [ $argcnt -gt 3 ]; then
        			echo "Error: too many parameters"
				continue
			fi
			;; 
		shutdown)
			# everything is fine
			;;
		exit)
			cleanup
			exit 0
			;;
	 	*)
			echo "Error: bad request"
			cleanup
			exit 1
	esac
	message="${req_command} $client_id ${command_arr[@]}"
#	echo "[SEND]$message"
	echo $message > $server_pipe
#	echo "[SENT]$message"

	# Read response from server pipe
	while read response; do
		echo "$response";
		if [ "$response" = "OK: shutting down server.." ]; then
			cleanup
			echo "Exit now."
			exit 0
		fi
	done < $client_pipe

#	echo "[DEBUG] end outer loop!!!"
done

