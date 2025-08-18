#!/bin/bash

help() {
    echo "Bitte wähle eine Aktion:"
    for action in ${ACTIONS[@]}
    do
        echo "- ${0} ${action}"
    done
}

write() {
    current_directory="$(pwd)"
    working_directory="${1}"

    file="${2}"
    title="${3}"
    heading="${4}"

    # Day Template
    if [ ! -f "${file}" ]
    then
        cat > "${file}" <<EOF
# 💭 Journal - ${title}
EOF
    fi

    # Entry Template
    cat >> "${file}" <<EOF

## ${heading} 

EOF

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

search() {
    read -p "Suche: " query
    if [[ -z "${query}" ]]
    then
        return 1
    fi

    grep --recursive --binary-files=without-match \
        --line-number --with-filename --color=always \
        "${1}" \
        --ignore-case --context=1 \
        --regexp="${query}"
}

count_words() {
    source_directory="${1}"

    printf "Wörter im Journal: "

    (for entry in "${source_directory}/"*".md"
    do
        cat "${entry}"
    done) \
        | wc -w
}

#
# Commandline Arguments
#

ACTIONS=("write" "search" "words")

if [ $# -lt 1 ]
then
    help
    exit 1
fi

#
# Dates
#

YEAR="$(date +%Y)"
MONTH="$(date +%m)"
DAY="$(date +%d)"

NOW="$(date +%R)"

#
# Directories
#

BASE_DIRECTORY="$(xdg-user-dir DOCUMENTS)/Notizen"
mkdir --parent "${BASE_DIRECTORY}"

SOURCE_DIRECTORY="${BASE_DIRECTORY}/Journal"
mkdir --parent "${SOURCE_DIRECTORY}"

PDF_DIRECTORY="${SOURCE_DIRECTORY}/PDF"
mkdir --parent "${PDF_DIRECTORY}"

#
# Actions
#

SOURCE_FILE="${SOURCE_DIRECTORY}/${YEAR}-${MONTH}-${DAY}.md"

PDF_FILE="${PDF_DIRECTORY}/Journal.pdf"
PDF_TITLE="Journal"

case ${1} in

    "${ACTIONS[0]}")
        if [ $# -lt 2 ]
        then
            PURPOSE=""
        else
            PURPOSE=" - ${2}"
        fi

        write "${BASE_DIRECTORY}" "${SOURCE_FILE}" "${YEAR}-${MONTH}-${DAY}" "${NOW}${PURPOSE}"
        ;;

    "${ACTIONS[1]}")
        search "${BASE_DIRECTORY}"
        ;;

    "${ACTIONS[2]}")
        count_words "${SOURCE_DIRECTORY}"
        ;;

    *)
        echo "Unbekannte Aktion"
        help
        exit 1
        ;;
esac
