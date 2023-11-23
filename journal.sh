#!/bin/bash

JDIR="${HOME}/Documents/Journal"

if [[ "$1" = "cat" ]]
then
    glow "${JDIR}/${2}.md"
elif [[ "$1" = "list" ]]
then
    tree "${JDIR}"
elif [[ "$1" = "find" ]]
then
    find "${JDIR}" -type f -name "*${2}*.md" -print
elif [[ "$1" = "rm" ]]
then
    if [[ -z "$2" ]]
    then
        echo "$0 $1 <note>"
    else
        rm -i "${JDIR}/${2}.md"
    fi
else
    if [[ -z "$1" ]]
    then
        DAY="$(date +%Y-%m-%d)"
    else
        DAY="${1}"
    fi

    $EDITOR "${JDIR}/${DAY}.md"
fi
