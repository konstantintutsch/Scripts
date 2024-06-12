#!/bin/bash

LAST="$(pwd)"

DOWN="${HOME}/Downloads/firefox-gnome-theme"
DEST="${HOME}/.var/app/io.gitlab.librewolf-community/.librewolf"

# Download
git clone https://github.com/rafaelmardojai/firefox-gnome-theme.git "${DOWN}"
cd "${DOWN}"

# Install
LWVER="$(flatpak run io.gitlab.librewolf-community --version | tr -d "[a-zA-Z] " | sed -e 's/.[0-9]-[0-9]//g')"
git checkout "v${LWVER}"
./scripts/install.sh -f "${DEST}"

# Finish
if [[ ${DOWN} != "/" ]]
then
    echo "Deleting ${DOWN}"
    rm -rf --interactive=never "${DOWN}"
else
    echo "Skipping deletion of ${DOWN}. Dangerous!"
fi
cd "${LAST}"
