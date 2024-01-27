#!/bin/bash

# export HIDRIVE_USER
#
# and
#
# export HIDRIVE_PASS
#
# or
#
# upload SSH public key to HiDrive

notification() {
    notify-send "$1" "$2"
    echo "$2"
}

if [[ $2 != "skipnetworkcheck" ]]
then
    count=0
    echo "Network:"
    while [[ -z "$(ip address | grep -F "192.168.178.")" ]]
    do
        count=$((count+1))
        if [[ $count -gt 15 ]]; then notification "$0" "Network timeout after 15s"; exit; fi
        echo "${count} - Waiting for network connection …"
        sleep 1
    done
    echo "Connected!"
else
    echo "Skipping network check …"
fi

RSYNC_ARGS='--human-readable \
            --partial \
            --progress \
            --archive \
            --executability \
            --compress \
            --verbose \
            --rsh=ssh \
            --exclude "*cache*" \
            --exclude "*Cache*" \
            --exclude "*thumbnails*" \
            --exclude "*Thumbnails*" \
            --exclude ".local/share/Trash" \
            --exclude ".local/share/baloo" \
            --exclude ".local/share/flatpak" \
            --exclude ".mnt" \
            --exclude "Public" \
            --exclude "Downloads" \
            --exclude "Desktop" \
            --exclude ".java" \
            --exclude ".gphoto" \
            --exclude ".pki" \
            --exclude ".tcc" \
            --update'

LOCAL_FOLDER="${HOME}"
HIDRIVE="${HIDRIVE_USER}@rsync.hidrive.strato.com:/users/${HIDRIVE_USER}"

push() {
    echo "Pushing …"
    eval "rsync $RSYNC_ARGS --delete --delete-excluded --force ${LOCAL_FOLDER}/ ${HIDRIVE}"
}
pull() {
    echo "Pulling …"
    eval "rsync $RSYNC_ARGS ${HIDRIVE}/ ${LOCAL_FOLDER}"
}

if [[ -z $1 ]]
then
    read -p "First? [pull/push]: " FIRST
else
    FIRST="${1}"
fi

if [[ "${FIRST}" == "pull" ]]
then
    pull
    push
elif [[ "${FIRST}" == "push" ]]
then
    push
    pull
else
    notification "$0" "Unknown action: ${FIRST}"
    exit 1
fi

notification "$0" "Sync complete"
