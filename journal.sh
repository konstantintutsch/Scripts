#!/bin/bash

#
# Purpose
#

if [ $# -lt 1 ]
then
    PURPOSE=""
else
    PURPOSE=" - ${1}"
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
# Editing
#

FILE="${SOURCE_DIRECTORY}/${DAY}.md"

# Day Template
if [ ! -f "${FILE}" ]
then
    cat > "${FILE}" <<EOF
# ${TODAY}
EOF
fi

# Entry Template
cat >> "${FILE}" <<EOF

## ${NOW}${PURPOSE} 

EOF

# Enter editor
if [[ "${EDITOR}" == *"vim" || "${EDITOR}" == *"*nvim" ]]
then
    "${EDITOR}" + "${FILE}"
else
    "${EDITOR}" "${FILE}"
fi

#
# PDF
#

pandoc "${SOURCE_DIRECTORY}/"*".md" \
    --output "${PDF_DIRECTORY}/${YEAR}-${MONTH}.pdf" \
    --metadata title="Journal für ${MONTH_NAME} ${YEAR}"
