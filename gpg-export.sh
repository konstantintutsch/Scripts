#1/bin/bash

GPG_EXP_DIR="${HOME}/Anwendungen/GPG"

if [[ -z "${1}" ]]
then
    echo "Please specify a key pair. (${0} mail@example.com)"
    exit
fi

gpg --output "${GPG_EXP_DIR}/public.asc" --armor --export "${1}"
gpg --output "${GPG_EXP_DIR}/secret.asc" --armor --export-secret-key "${1}"

