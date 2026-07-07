#!/bin/zsh

branch="${1}"
if [ -z "${branch}" ]
then
    echo "${0} <branch>"
    exit 1
fi

git commit --signoff "${branch}"
