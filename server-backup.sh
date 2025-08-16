#!/bin/bash

# Exit on error
set -eE
trap "{ notify-send --urgency=critical '🔴 Server Backup Failed' 'An error occurred at command “${BASH_COMMAND}”'; }" ERR

#
# Internal script configuration
#

DATE="$(date +%Y%m%d)"

LOCAL="notolaf" # The server to connect to
ADDRESS_SPACE="192.168.178." # The server's network address space - if SSH is only possible from within this network

# Locations
DATA_DIRECTORY_LOCAL="/mnt/storage"
BACKUP_DIRECTORY="${HOME}/Hosting" # The backup location

# Copy names
COPY_INIT="systemd.service"
COPY_WEBSERVER="httpd.conf"
COPY_DATABASE="postgres.sql"
COPY_DOCKER="docker-compose.yaml"

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
    mkdir -p "${BACKUP_DIRECTORY}/$(dirname $4)"
    scp "$2"@"$1":"$3" "${BACKUP_DIRECTORY}/$4"
}

download_local() {
    USER="${3}"
    if [[ -z ${USER} ]]
    then
        USER="konstantin"
    fi

    download "$LOCAL" "${USER}" "$1" "${LOCAL}/$2"
}

download_directory() {
    mkdir -p "${BACKUP_DIRECTORY}/$(dirname $4)/directory"
    rsync --verbose --archive --recursive --delete "$2"@"$1":"$3" "${BACKUP_DIRECTORY}/$(dirname $4)/directory"
}

download_directory_local() {
    download_directory "$LOCAL" "konstantin" "$1" "${LOCAL}/$2"
}

if [[ ! -d "${BACKUP_DIRECTORY}" ]]
then
    mkdir -p "${BACKUP_DIRECTORY}"
fi

#
# Umami
#

UMAMI="umami"
UMAMI_DB="~/umami.sql"

ssh "konstantin"@"$LOCAL" "docker exec umami-db-1 pg_dump -U ${UMAMI} -d ${UMAMI} > ${UMAMI_DB}"
download_local "${UMAMI_DB}" "${UMAMI}/${COPY_DATABASE}"
ssh "konstantin"@"$LOCAL" "rm ${UMAMI_DB}"
download_local "/etc/httpd/conf.d/umami.conf" "${UMAMI}/${COPY_WEBSERVER}"
download_local "/etc/systemd/system/umami.service" "${UMAMI}/${COPY_INIT}"
download_local "/home/umami/docker-compose.yaml" "${UMAMI}/${COPY_DOCKER}" "umami"

#
# Endurain
#

ENDURAIN="endurain"
ENDURAIN_DB="~/endurain.sql"

ssh "konstantin"@"$LOCAL" "docker exec endurain-postgres pg_dump -U ${ENDURAIN} -d ${ENDURAIN} > ${ENDURAIN_DB}"
download_local "${ENDURAIN_DB}" "${ENDURAIN}/${COPY_DATABASE}"
ssh "konstantin"@"$LOCAL" "rm ${ENDURAIN_DB}"
download_directory_local "/opt/endurain/backend" "${ENDURAIN}/directory"
download_local "/etc/httpd/conf.d/endurain.conf" "${ENDURAIN}/${COPY_WEBSERVER}"
download_local "/etc/systemd/system/endurain.service" "${ENDURAIN}/${COPY_INIT}"
download_local "/opt/endurain/docker-compose.yaml" "${ENDURAIN}/${COPY_DOCKER}"


#
# Websites
#

WEBSERVER="httpd"

download_local "/etc/httpd/conf.d/base.conf" "${WEBSERVER}/base.conf"

download_local "/etc/httpd/conf.d/konstantintutsch.com.conf" "${WEBSERVER}/konstantintutsch.com.conf"
download_local "/etc/httpd/conf.d/konstantintutsch.de.conf" "${WEBSERVER}/konstantintutsch.de.conf"
download_local "/etc/httpd/conf.d/apps.conf" "${WEBSERVER}/apps.conf"

#
# Syncthing
#

download "$LOCAL" "syncthing" "/home/syncthing/.local/state/syncthing/config.xml" "${LOCAL}/syncthing.xml"

#
# Conduit
#

CONDUIT="conduit"

download_local "/etc/systemd/system/conduit.service" "${CONDUIT}/${COPY_INIT}"
download_local "/etc/httpd/conf.d/conduit.conf" "${CONDUIT}/${COPY_WEBSERVER}"
download_local "/home/conduit/download.sh" "${CONDUIT}/download.sh" "conduit"
download_local "/home/conduit/config.toml" "${CONDUIT}/config.toml" "conduit"
download_directory "$LOCAL" "conduit" "/home/conduit/database" "${LOCAL}/${CONDUIT}/directory"
download_directory "$LOCAL" "conduit" "/home/conduit/media" "${LOCAL}/${CONDUIT}/directory"

#
# Anki
#

ANKI="anki"

download_local "/etc/systemd/system/anki.service" "${ANKI}/${COPY_INIT}"
download_local "/etc/httpd/conf.d/anki.conf" "${ANKI}/${COPY_WEBSERVER}"
download_directory "$LOCAL" "anki" "/home/anki/sync" "${LOCAL}/${ANKI}/directory"

#
# DDClient
#

DDCLIENT="ddclient"

download_local "/etc/systemd/system/ddclient@.service" "${DDCLIENT}/${COPY_INIT}"
download_local "/etc/ddclient-konstantintutsch.de.conf" "${DDCLIENT}"
download_local "/etc/ddclient-konstantintutsch.com.conf" "${DDCLIENT}"

#
# System
#

DNF="dnf"
FAIL2BAN="fail2ban"

download_local "~/firewalld.sh" "firewalld.sh"
download_local "/etc/dnf/automatic.conf" "${DNF}/automatic.conf"
download_local "~/dnfmail.sh" "${DNF}/dnfmail.sh"

#
# Success
#

if [[ "$1" != "force" ]]
then
    touch "$SAVE"
fi

notify-send --urgency=normal "🟢 Server Backup Success" "All data backed up."
