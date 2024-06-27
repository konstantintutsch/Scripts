#!/bin/bash

# Exit on error
set -e
trap "{ notify-send --urgency=critical '🔴 Server Backup Failed' 'An error occured.'; }" ERR

#
# Internal script configuration
#

DATE="$(date +%Y%m%d)"

HOST="rpi-homeserver" # The server to connect to
ADDRESS_SPACE="192.168.178." # The server's network address space - if SSH is only possible from within this network

# Locations
DATA_DIRECTORY="/mnt/storage"
BACKUP_DIRECTORY="${HOME}/RaspberryPi" # The backup location

# Copy names
COPY_INIT="systemd.service"
COPY_WEBSERVER="httpd.conf"
COPY_DATABASE="mariadb.sql"

# External configuration file - add / overwrite shell variables - used for database credentials
EXTERNAL_CONFIG="${HOME}/Code/Scripts/.server-backup.conf" # .gitignore -> avoid db credential leak

if [[ ${EXTERNAL_CONFIG} == "" || -z ${EXTERNAL_CONFIG} ]]
then
    echo "Please create a configuration based on templates/server-backup.conf and set EXTERNAL_CONFIG in server-backup.sh to the configuration file's path before runnig this script."
    exit 1
else
    for line in $(cat ${EXTERNAL_CONFIG})
    do
        eval "export ${line}"
    done
fi

if [[ "$1" != "force" ]]
then
    SAVE="${HOME}/.server-backup-done"

    # Only back up on Thursdays
    if [[ $(date +%u) != "4" ]]
    then
        echo "It is not Thursday."
        if [[ -f $SAVE ]]; then rm "$SAVE"; fi
        exit
    fi
    echo "Thursday. Continuing!"

    if [[ -f $SAVE ]]
    then
        echo "Backup was already done!"
        exit
    fi
else
    echo "Forcing backup …"
fi

count=0
echo "Netzwerk:"
while [[ -z "$(ip address | grep -F "${ADDRESS_SPACE}")" ]]
do
    count=$((count+1))
    if [[ $count -gt 15 ]]; then echo "Timeout after 15 seconds"; exit; fi
    echo "${count} - Checking network …"
    sleep 1
done
echo "Connected!"

download() {
    mkdir -p "${BACKUP_DIRECTORY}/$(dirname $2)"
    scp "root"@"$HOST":"$1" "${BACKUP_DIRECTORY}/$2"
}

if [[ ! -d "${BACKUP_DIRECTORY}" ]]
then
    mkdir -p "${BACKUP_DIRECTORY}"
fi

#
# Radicale
#

RADICALE="radicale"

download "/etc/radicale/config" "${RADICALE}/config"
download "/etc/systemd/system/radicale.service" "${RADICALE}/${COPY_INIT}"
download "/etc/httpd/conf.d/radicale.conf" "${RADICALE}/${COPY_WEBSERVER}"
rsync -Avrlt --del --force "root"@"$HOST":"${DATA_DIRECTORY}/radicale/radicale" "${BACKUP_DIRECTORY}/${RADICALE}/directory"

#
# Umami
#

UMAMI="umami"
UMAMI_DB="${DATA_DIRECTORY}/umami.sql"
# UMAMI_DB_NAME
# UMAMI_DB_USER
# UMAMI_DB_PASSWORD

ssh "root"@"$HOST" "mariadb-dump -u${UMAMI_DB_USER} -p${UMAMI_DB_PASSWORD} ${UMAMI_DB_NAME} > ${UMAMI_DB}"
download "${UMAMI_DB}" "${UMAMI}/${COPY_DATABASE}"
ssh "root"@"$HOST" "rm ${UMAMI_DB}"
download "/etc/httpd/conf.d/umami.conf" "${UMAMI}/${COPY_WEBSERVER}"
download "/etc/systemd/system/umami.service" "${UMAMI}/${COPY_INIT}"

#
# DDClient
#

DDCLIENT="ddclient"
DDCLIENT_PREFIX="ddclient"

download "/etc/ddclient4.conf" "${DDCLIENT}/${DDCLIENT_PREFIX}4.conf"
download "/etc/ddclient6.conf" "${DDCLIENT}/${DDCLIENT_PREFIX}6.conf"
download "/etc/systemd/system/ddclient@.service" "${DDCLIENT}/ddclient@.service"

#
# SFTPGo
#

SFTPGO="sftpgo"
SFTPGO_DB="${DATA_DIRECTORY}/sftpgo.sql"
# SFTPGO_DB_NAME
# SFTPGO_DB_USER
# SFTPGO_DB_PASSWORD

ssh "root"@"$HOST" "mariadb-dump -u${SFTPGO_DB_USER} -p${SFTPGO_DB_PASSWORD} ${SFTPGO_DB_NAME} > ${SFTPGO_DB}"
download "${SFTPGO_DB}" "${SFTPGO}/${COPY_DATABASE}"
ssh "root"@"$HOST" "rm ${SFTPGO_DB}"
download "/etc/sftpgo/sftpgo.json" "${SFTPGO}/sftpgo.json"
rsync -Avrlt --del --force "root"@"$HOST":"${DATA_DIRECTORY}/sftpgo" "${BACKUP_DIRECTORY}/${SFTPGO}/directory"
download "/etc/httpd/conf.d/sftpgo.conf" "${SFTPGO}/${COPY_WEBSERVER}"

#
# Websites
#

WEBSERVER="httpd"

download "/etc/httpd/conf.d/konstantintutsch.com.conf" "${WEBSERVER}/konstantintutsch.com.conf"

#
# System
#

DNF="dnf"

download "/etc/fstab" "fstab"
download "/etc/dnf/automatic.conf" "${DNF}/automatic.conf"
download "/root/dnfmail.sh" "${DNF}/dnfmail.sh"

#
# Success
#

if [[ "$1" != "force" ]]
then
    touch "$SAVE"
fi

notify-send --urgency=normal "🟢 Server Backup Success" "All data backed up."
