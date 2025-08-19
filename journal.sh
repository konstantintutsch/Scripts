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
# ${title}
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

words() {
    source_directory="${1}"

    printf "Wörter im Journal: "

    (for entry in "${source_directory}/"*".md"
    do
        cat "${entry}"
    done) \
        | wc -w
}

render() {
    source_directory="${1}"
    pdf_path="${2}"
    title="${3}"

    pandoc $(ls --reverse ${source_directory}/*.md) \
        --output "${pdf_path}" \
        --metadata title="${title}"
}

#
# Commandline Arguments
#

ACTIONS=("write" "search" "words" "render")

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

SOURCE_TITLE="${YEAR}-${MONTH}-${DAY}"
SOURCE_FILE="${SOURCE_DIRECTORY}/${SOURCE_TITLE}.md"

PDF_TITLE="Journal"
PDF_FILE="${PDF_DIRECTORY}/Journal.pdf"

case ${1} in

    "${ACTIONS[0]}")
        if [ $# -lt 2 ]
        then
            PURPOSE=""
        else
            PURPOSE=" - ${2}"
        fi

        write "${BASE_DIRECTORY}" "${SOURCE_FILE}" "${SOURCE_TITLE}" "${NOW}${PURPOSE}"
        render "${SOURCE_DIRECTORY}" "${PDF_FILE}" "${PDF_TITLE}"
        ;;

    "${ACTIONS[1]}")
        search "${BASE_DIRECTORY}"
        ;;

    "${ACTIONS[2]}")
        count_words "${SOURCE_DIRECTORY}"
        ;;

    "${ACTIONS[3]}")
        render "${SOURCE_DIRECTORY}" "${PDF_FILE}" "${PDF_TITLE}"
        ;;

    *)
        echo "Unbekannte Aktion"
        help
        exit 1
        ;;
esac
