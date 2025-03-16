#!/bin/bash

# Download source font
SOURCE="${HOME}/Downloads/AppleColorEmoji.ttf"
curl -L --verbose https://github.com/samuelngs/apple-emoji-linux/releases/latest/download/AppleColorEmoji.ttf -o "${SOURCE}"

# Disable alternative emoji fonts
DISABLE="<selectfont>
    <rejectfont>
        <glob>*NotoColorEmoji.ttf*</glob>
        <glob>/usr/share/fonts/noto-emoji/*</glob>
        <glob>/usr/share/fonts/google-noto-color-emoji-fonts/*</glob>
    </rejectfont>
</selectfont>"

# Install font for user
ROOT="${HOME}/.local/share/fonts"
FONT="${HOME}/.config/fontconfig"

# Install
mkdir --verbose --parent "${ROOT}"
cp --verbose "${SOURCE}" "${ROOT}"

# Disable alternatives
mkdir --verbose --parent "${FONT}"
echo "${DISABLE}" > "${FONT}/fonts.conf"

# Update fonts
fc-cache --verbose --force

# Install font to sandboxed apps (Flatpak)
for APP in "${HOME}/.var/app/"*
do
    ID="$(basename ${APP})"
    FLATPAK="${APP}/data/fonts"
    FONT="${APP}/config/fontconfig"

    # Install
    mkdir --verbose --parent "${FLATPAK}"
    cp --verbose "${SOURCE}" "${FLATPAK}"

    # Disable alternatives
    mkdir --verbose --parent "${FONT}"
    echo "${DISABLE}" > "${FONT}/fonts.conf"

    # Update
    flatpak run --command=fc-cache "${ID}" --verbose --force
done

# Remove source font
rm --verbose --interactive=never "${SOURCE}"
