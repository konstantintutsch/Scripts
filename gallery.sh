#!/bin/bash

help() {
    actions=("${@}")

    echo "Bitte wähle eine Aktion:"
    for action in "${actions[@]}"
    do
        echo "- ${0} ${action} <Datei>"
    done
}

time_key() {
    file="${1}"
    file_extension=$(echo "${file##*.}" | tr '[:upper:]' '[:lower:]')

    key="DateTimeOriginal"
    if [ "${file_extension}" = "mp4" ] || [ "${file_extension}" = "mov" ]
    then
        key="CreateDate"
    fi

    echo "${key}"
}

time_rename() {
    file="${1}"

    time=$(exiftool -d "%Y%m%dT%H%M%S" -"$(time_key "${file}")" -S -s "${file}")

    mv "${file}" "$(dirname "${file}")/${time}_$(basename "${file}")"
}

filesystem_time() {
    file="${1}"

    time=$(exiftool -d "%Y%m%d%H%M.%S" -"$(time_key "${file}")" -S -s "${file}")

    touch -t "${time}" "${file}"
}

import() {
    file="${1}"
    target="${2}/$(basename "${file}")"

    mv "${file}" "${target}"

    filesystem_time "${target}"
    time_rename "${target}"
}

#
# Commandline Arguments
#

ACTIONS=("import" "rename" "time")

if [ $# -lt 2 ]
then
    help "${ACTIONS[@]}"
    exit 1
fi

#
# File
#

FILE="${2}"

if [ ! -f "${FILE}" ]
then
    echo "${FILE} existiert nicht"
    exit 1
fi

if [ ! -r "${FILE}" ]
then
    echo "${FILE} ist nicht lesbar"
    exit 1
fi

if [ ! -w "${FILE}" ]
then
    echo "${FILE} ist nicht schreibbar"
    exit 1
fi

#
# Actions
#

GALLERY="$(xdg-user-dir PICTURES)"

case ${1} in

    "${ACTIONS[0]}")
        album="${3}"
        if [ -z "${album}" ]
        then
            read -p "Album: " album
        fi

        import "${FILE}" "${GALLERY}/${album}"
        ;;

    "${ACTIONS[1]}")
        time_rename "${FILE}"
        ;;

    "${ACTIONS[2]}")
        filesystem_time "${FILE}"
        ;;

    *)
        echo "Unbekannte Aktion"
        help "${ACTIONS[@]}"
        exit 1
        ;;
esac
