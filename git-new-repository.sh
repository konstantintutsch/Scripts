#!/bin/zsh

SERVER="git@konstantintutsch.com"

read "name?Name: "
if [ ! "${name}" ]; then exit 1; fi

REPOSITORY="${name}.git"

# create and initialize repository on server
ssh ${SERVER} git init "${REPOSITORY}"

echo "Created repository at ${SERVER}:${REPOSITORY}"
