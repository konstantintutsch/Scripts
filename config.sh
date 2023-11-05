#!/bin/bash

LOCAL="$HOME/Anwendungen/$HOSTNAME"
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
	echo "Konfigurationsdatei muss angegeben werden."
	exit 1
fi
