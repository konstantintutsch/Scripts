#!/bin/bash

NDIR="${HOME}/Dokumente/Notizen"

if [[ "$1" = "cat" ]]
then
    glow "${NDIR}/${2}.md"
elif [[ "$1" = "list" ]]
then
    tree "${NDIR}"
elif [[ "$1" = "find" ]]
then
    find "${NDIR}" -type f -name "*${2}*.md" -print
elif [[ "$1" = "rm" ]]
then
    if [[ -z "$2" ]]
    then
        echo "$0 $1 <note>"
    else
        rm -i "${NDIR}/${2}.md"
    fi
else
    if [[ -z "$1" ]]
    then
        NOTE="Schnellnotiz"
    else
        NOTE="${1}"
    fi

    $EDITOR "${NDIR}/${NOTE}.md"
fi
