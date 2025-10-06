#!/bin/bash

# Exit on error
set -eE
trap "{ echo 'An error occurred at command “${BASH_COMMAND}”' }" ERR

# Mount backup disk
DISK_DIRECTORY="/dev"

lsblk
read -p "Disk: ${DISK_DIRECTORY}/" disk
if [ ! "${disk}" ]; then exit 1; fi
MOUNT_DIRECTORY="/mnt/${disk}"

mkdir --parents "${MOUNT_DIRECTORY}"
mount "${DISK_DIRECTORY}/${disk}" "${MOUNT_DIRECTORY}"

# Create backup
export BORG_REPO="${MOUNT_DIRECTORY}/borg"

read -s -p "Passphrase: " passphrase
if [ "${passphrase}" ]; then export BORG_PASSPHRASE=${passphrase}; fi

borg create                                             \
    --verbose                                           \
    --filter AMCE                                       \
    --list                                              \
    --stats                                             \
    --compression lzma                                  \
    --exclude-caches                                    \
    --exclude '*/.cache/*'                              \
    --exclude '*/tmp/*'                                 \
    --exclude 'home/borg/*'                             \
    --exclude 'home/factorio/temp'                      \
    --exclude '*/_data/models/*'                        \
    --exclude 'opt/immich/library/thumbs/*'             \
    --exclude 'opt/immich/library/encoded-video/*'      \
                                                        \
    ::'{now}'                                           \
    /etc                                                \
    /home                                               \
    /root                                               \
    /opt

# Prune repository
borg prune                 \
    --list                 \
    --keep-daily   14      \
    --keep-weekly   4      \
    --keep-monthly 24      \
    --keep-yearly   5

# Compact repository
borg compact

# Unmount backup disk
umount "${MOUNT_DIRECTORY}"
