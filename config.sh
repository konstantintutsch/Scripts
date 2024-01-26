#!/bin/bash

LOCAL="$HOME/Documents/Software/$HOSTNAME"
CURR_DIR="$(pwd)"

if [[ "$1" ]]
then
    CONFIG="$(find "${LOCAL}" -wholename "*/${1}")"
    CONFIG="${CONFIG//${LOCAL}\//}"

	cd "$LOCAL" || exit
	"$EDITOR" "./${CONFIG}"
	sudo cp -v "./${CONFIG}" "/${CONFIG}"
	
	cd "$CURR_DIR" || exit
else 
	echo "A configuration needs to be specified"
	exit 1
fi
