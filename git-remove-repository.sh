#!/bin/zsh

SERVER="git@konstantintutsch.com"

read "name?Name: "
if [ ! "${name}" ]; then exit 1; fi

REPOSITORY="${name}.git"

# delete repository on server
echo "rm: ${REPOSITORY}"
ssh ${SERVER} rm -IR "${REPOSITORY}"

echo "Removed repository ${SERVER}:${REPOSITORY}"
