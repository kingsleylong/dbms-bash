#!/bin/bash

while true; do
	# read commands into an array
	read -a command_arr 
	# get the first
	req_command=${command_arr[0]}
	# remove the first element which is the command, so the rest of array would be parameters
	# for this command which we could simply pass into the script later
	unset 'command_arr[0]'
	case "${req_command}" in
		create_database)
			./create_database.sh "${command_arr[@]}" &
			;;
		create_table)
			./create_table.sh "${command_arr[@]}" &
			;;
		insert)
			./insert.sh "${command_arr[@]}" &
			;; 
		select)
			./select.sh "${command_arr[@]}" &
			;; 
		shutdown)
			echo "Good bye."
			exit 0
			;;
	 	*)
			echo "Error: bad request"
			exit 1
	esac
done
