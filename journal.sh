#!/bin/bash

help() {
    echo "Bitte wähle eine Aktion:"
    for action in ${ACTIONS[@]}
    do
        echo "- ${0} ${action}"
    done
}

write() {
    file="${1}"
    title="${2}"
    heading="${3}"

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
        "${EDITOR}" + "${file}"
    else
        "${EDITOR}" "${file}"
    fi
}

render() {
    source_directory="${1}"
    pdf_path="${2}"
    title="${3}"

    pandoc "${source_directory}/"*".md" \
        --output "${pdf_path}" \
        --metadata title="${title}"
}

count_words() {
    pdf_directory="${1}"

    printf "Wörter im Journal: "

    (for pdf in "${pdf_directory}/"*".pdf"
    do
        pdftotext "${pdf}" -
    done) \
        | wc -w
}

#
# Commandline Arguments
#

ACTIONS=("write" "render" "words")

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
MONTH_NAME="$(date +%B)"

DAY="$(date +%d)"
DAY_NAME="$(date +%A)"

TODAY="${DAY_NAME}, ${DAY}. ${MONTH_NAME}"
NOW="$(date +%R)"

#
# Directories
#

BASE_DIRECTORY="$(xdg-user-dir DOCUMENTS)/Journal"
mkdir --parent "${BASE_DIRECTORY}"

SOURCE_DIRECTORY="${BASE_DIRECTORY}/Source/${YEAR}/${MONTH}"
mkdir --parent "${SOURCE_DIRECTORY}"

PDF_DIRECTORY="${BASE_DIRECTORY}"
mkdir --parent "${PDF_DIRECTORY}"

#
# Actions
#

SOURCE_FILE="${SOURCE_DIRECTORY}/${DAY}.md"

PDF_FILE="${PDF_DIRECTORY}/${YEAR}-${MONTH}.pdf"
PDF_TITLE="Journal für ${MONTH_NAME} ${YEAR}"

case ${1} in

    "${ACTIONS[0]}")
        if [ $# -lt 2 ]
        then
            PURPOSE=""
        else
            PURPOSE=" - ${2}"
        fi

        write "${SOURCE_FILE}" "${TODAY}" "${NOW}${PURPOSE}"
        render "${SOURCE_DIRECTORY}" "${PDF_FILE}" "${PDF_TITLE}"
        ;;

    "${ACTIONS[1]}")
        render "${SOURCE_DIRECTORY}" "${PDF_FILE}" "${PDF_TITLE}"
        ;;

    "${ACTIONS[2]}")
        count_words "${PDF_DIRECTORY}"
        ;;

    *)
        echo "Unbekannte Aktion"
        help
        exit 1
        ;;
esac
