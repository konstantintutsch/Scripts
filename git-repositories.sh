#!/bin/zsh

SERVER="git@konstantintutsch.com"

# get repositories (including all depths)
REPOSITORIES=$(
    ssh ${SERVER} \
        'find . -type d \( -name "*.git" -and -not -name ".git" \) -printf "%P\n"'
)

# print full remote location (with server as prefix)
for repository in ${(f)REPOSITORIES}
do
    echo "${SERVER}:${repository}"
done
