#!/bin/bash

write() {
    current_directory="$(pwd)"
    working_directory="${1}"

    file="${2}"
    title="${3}"

    if [ ! -f "${file}" ]
    then
        cat > "${file}" <<EOF
# 🌱 Log - ${title}

- 
EOF
    fi

    # Enter editor
    if [[ "${EDITOR}" == *"vim" || "${EDITOR}" == *"*nvim" ]]
    then
        cd "${working_directory}" || echo "Arbeitsverzeichnis konnte nicht betreten werden"
        "${EDITOR}" + "${file}"
        cd "${current_directory}" || echo "Arbeitsverzeichnis konnte nicht verlassen werden"
    else
        "${EDITOR}" "${file}"
    fi
}

#
# Dates
#

YEAR="$(date +%Y)"
MONTH="$(date +%m)"
DAY="$(date +%d)"

#
# Directories
#

BASE_DIRECTORY="$(xdg-user-dir DOCUMENTS)/Notizen"
mkdir --parent "${BASE_DIRECTORY}"

SOURCE_DIRECTORY="${BASE_DIRECTORY}/Log"
mkdir --parent "${SOURCE_DIRECTORY}"

#
# Actions
#

SOURCE_FILE="${SOURCE_DIRECTORY}/${YEAR}-${MONTH}-${DAY}.md"

write "${BASE_DIRECTORY}" "${SOURCE_FILE}" "${YEAR}-${MONTH}-${DAY}"
