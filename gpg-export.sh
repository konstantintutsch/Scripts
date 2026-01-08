#1/bin/bash

TARGET_DIRECTORY="${HOME}/Downloads"

if [[ -z "${1}" ]]
then
    echo "Please specify a key pair. (${0} mail@example.com)"
    exit
fi

gpg --output "${TARGET_DIRECTORY}/${1}-public.pgp" --export "${1}"
gpg --output "${TARGET_DIRECTORY}/${1}-secret.pgp" --export-secret-key "${1}"
