#!/bin/bash

LOGFILE="backup.log"

# Clean up logfile
if [ -f "$LOGFILE" ]
then
	rm --interactive=never "$LOGFILE"
fi

# Run screen if not already inside
if [ -z "$STY" ]
then
	exec screen -L -Logfile "$LOGFILE" -S backup /bin/bash "$0"
fi

if [ ! "${1}" ]
then
	read -p "Target [disk/cloud]: " target
else
	target="${1}"
fi

if [ "${target}" == "disk" ]
then
	# Mount backup disk
	DISK_DIRECTORY="/dev"

	lsblk
	read -p "Disk: ${DISK_DIRECTORY}/" disk
	if [ ! "${disk}" ]; then exit 1; fi
	MOUNT_DIRECTORY="/mnt/${disk}"

	mkdir --parents "${MOUNT_DIRECTORY}"
	mount "${DISK_DIRECTORY}/${disk}" "${MOUNT_DIRECTORY}"
elif [ "${target}" == "cloud" ]
then
	# Mount backup storage
	MOUNT_DIRECTORY="/mnt/cloud"

	mkdir --parents "${MOUNT_DIRECTORY}"
	sshfs -o allow_root,uid=0,gid=0 -p 23 cloud:/home "${MOUNT_DIRECTORY}"
else
	echo "Unknown target ${target}"
	exit 1
fi

# Create backup
export BORG_REPO="${MOUNT_DIRECTORY}/borg"

read -s -p "Passphrase: " passphrase
if [ $passphrase ]
then
	export BORG_PASSPHRASE=$passphrase
fi

borg create --verbose \
    --filter AMCE \
    --list \
    --stats \
    --compression lzma \
    --exclude-caches \
    --exclude '*/.cache/*' \
    --exclude '*/cache/*' \
    --exclude '*/tmp/*' \
    ::'{now}' \
    /etc \
    /home \
    /root \
    /opt

# Prune repository
borg prune \
    --list \
    --keep-daily 14 \
    --keep-weekly 4 \
    --keep-monthly 24 \
    --keep-yearly 5

# Compact repository
borg compact

if [ "${target}" == "disk" ]
then
	# Unmount backup disk
	umount "${MOUNT_DIRECTORY}"
elif [ "${target}" == "cloud" ]
then
	# Unmount backup storage
	fusermount -u "${MOUNT_DIRECTORY}"
fi
