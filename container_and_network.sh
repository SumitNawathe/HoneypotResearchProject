#!/bin/bash

# network data structures
CONTAINERS=()
ROUTER=""
SIZE=0


# container utility functions
get_ip() {
   local CONTAINER_NAME=$1
   NAME_EXISTS=$(sudo lxc-ls | grep "$CONTAINER_NAME")
   IP=""

   if [[ -n "$NAME_EXISTS" ]]; then
	$IP=$(sudo lxc-info -n "$CONTAINER_NAME" | grep "IP" | awk '{ print $2 }')
	   
   fi
	
   echo "$IP"
}

is_running() {
   local CONTAINER_NAME=$1
   running=$(sudo lxc-info -n "$CONTAINER_NAME" | grep "State" | awk '{ print $2 }')

   if [[ $running == "RUNNING" ]] ; then
   	return 1;
   else 
   	return 0;
   fi
}

# network serialization
create_network_from_file() {
   local FILENAME=$1

   i=0
   while IFS="" read -r p || [ -n "$p" ]
   do
	   LINE=$(printf '%s\n' "$p")
	   if [[ i -eq 0 ]]; then
		   SIZE=$( echo "$LINE" | awk '{ print $2 }')
	   fi

	   if [[ i -eq 1 ]]; then
		   ROUTER=$( echo "$LINE" | awk '{ print $2 }')
		   CREATE=$(ruby -e "require './container'; puts Container.new('$ROUTER').create")
	   fi

	   if [[ i -ge 2 ]]; then
		   CONTAINER_NAME=$( echo "$LINE" | awk '{ print $2 }' )
		   CONTAINERS=(${CONTAINERS[@]} "$CONTAINER_NAME")
		   CREATE=$(ruby -e "require './container'; puts Container.new('$CONTAINER_NAME').create")
    	   fi
	
	   i=$(( $i + 1 ))
   done < $FILENAME
}

write_network_to_file() {
   local FILENAME=$1
   
   echo "SIZE $SIZE" > "$FILENAME"
   echo "ROUTER $ROUTER" >> "$FILENAME"
   for value in "${CONTAINERS[@]}"
   do
	   echo "CONTAINER $value" >> "$FILENAME"
   done
}


