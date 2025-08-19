#!/bin/bash

# Exit on error
set -eE
trap "{ notify-send --urgency=critical '🔴 Server Backup Failed' 'An error occurred at command “${BASH_COMMAND}”'; }" ERR

#
# Internal script configuration
#

LOCAL="notolaf" # The server to connect to
ADDRESS_SPACE="192.168.178." # The server's network address space - if SSH is only possible from within this network

# Locations
BACKUP_DIRECTORY="${HOME}/Hosting" # The backup location

# Copy names
COPY_INIT="systemd.service"
COPY_WEBSERVER="httpd.conf"
COPY_DATABASE="postgres.sql"
COPY_DOCKER="docker-compose.yaml"

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

run() {
    user="${2}"
    host="${1}"
    command="${3}"

    echo "Running command on ${user}@${host}: ${command}"

    ssh "${user}"@"${host}" "${command}" 

    echo ""
}

run_local() {
    run "${LOCAL}" "konstantin" "${1}" 
}

download() {
    user="${2}"
    host="${1}"
    source="${3}"
    target="${BACKUP_DIRECTORY}/${4}"

    echo "Downloading file ${user}@${host}:${source} to ${target}"

    mkdir -p "$(dirname ${target})"
    scp "${user}"@"${host}":"${source}" "${target}"

    echo ""
}

download_local() {
    USER="${3}"
    if [[ -z ${USER} ]]
    then
        USER="konstantin"
    fi

    download "${LOCAL}" "${USER}" "$1" "${LOCAL}/$2"
}

download_directory() {
    user="${2}"
    host="${1}"
    source="${3}"
    target="${BACKUP_DIRECTORY}/${4}"

    echo "Downloading directory ${user}@${host}:${source} to ${target}"

    mkdir -p "${target}"
    rsync --verbose --archive --recursive --delete "${user}"@"${host}":"${source}" "${target}"

    echo ""
}

download_directory_local() {
    download_directory "${LOCAL}" "konstantin" "$1" "${LOCAL}/$2"
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

run_local "docker stop umami-app"
run_local "docker exec umami-db pg_dump -U ${UMAMI} -d ${UMAMI} > ${UMAMI_DB}"
run_local "docker start umami-app"
download_local "${UMAMI_DB}" "${UMAMI}/${COPY_DATABASE}"
run_local "rm ${UMAMI_DB}"
download_local "/etc/httpd/conf.d/umami.conf" "${UMAMI}/${COPY_WEBSERVER}"
download_local "/etc/systemd/system/umami.service" "${UMAMI}/${COPY_INIT}"
download_local "/opt/umami/docker-compose.yaml" "${UMAMI}/${COPY_DOCKER}"

#
# Endurain
#

ENDURAIN="endurain"
ENDURAIN_DB="~/endurain.sql"

run_local "docker stop endurain-app"
run_local "docker exec endurain-postgres pg_dump -U ${ENDURAIN} -d ${ENDURAIN} > ${ENDURAIN_DB}"
download_local "${ENDURAIN_DB}" "${ENDURAIN}/${COPY_DATABASE}"
run_local "rm ${ENDURAIN_DB}"
download_directory_local "/opt/endurain/backend" "${ENDURAIN}"
run_local "docker start endurain-app"
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

SYNCTHING="syncthing"

run_local "docker stop syncthing"
download_local "/opt/syncthing/data/config/config.xml" "${SYNCTHING}/config.xml"
run_local "docker start syncthing"
download_local "/etc/systemd/system/syncthing.service" "${SYNCTHING}/${COPY_INIT}"
download_local "/opt/syncthing/docker-compose.yaml" "${SYNCTHING}/${COPY_DOCKER}"

#
# Conduit
#

CONDUIT="conduit"

run_local "docker stop conduit"
download_directory_local "/opt/conduit/database" "${CONDUIT}"
run_local "docker start conduit"
download_local "/etc/httpd/conf.d/conduit.conf" "${CONDUIT}/${COPY_WEBSERVER}"
download_local "/etc/systemd/system/conduit.service" "${CONDUIT}/${COPY_INIT}"
download_local "/opt/conduit/docker-compose.yaml" "${CONDUIT}/${COPY_DOCKER}"

#
# Anki
#

ANKI="anki"

run_local "docker stop anki"
download_directory_local "/opt/anki/sync" "${ANKI}"
run_local "docker start anki"
download_local "/etc/httpd/conf.d/anki.conf" "${ANKI}/${COPY_WEBSERVER}"
download_local "/etc/systemd/system/anki.service" "${ANKI}/${COPY_INIT}"
download_local "/opt/anki/docker-compose.yaml" "${ANKI}/${COPY_DOCKER}"

#
# Beaver Habit Tracker
#

BEAVERHABITS="beaverhabits"

run_local "docker stop beaverhabits"
download_directory_local "/opt/beaverhabits/data" "${BEAVERHABITS}"
run_local "docker start beaverhabits"
download_local "/etc/httpd/conf.d/beaverhabits.conf" "${BEAVERHABITS}/${COPY_WEBSERVER}"
download_local "/etc/systemd/system/beaverhabits.service" "${BEAVERHABITS}/${COPY_INIT}"
download_local "/opt/beaverhabits/docker-compose.yaml" "${BEAVERHABITS}/${COPY_DOCKER}"


#
# Uptime Kuma
#

UPTIMEKUMA="uptime-kuma"

run_local "docker stop uptime-kuma"
download_directory_local "/opt/uptime-kuma/data" "${UPTIMEKUMA}"
run_local "docker start uptime-kuma"
download_local "/etc/httpd/conf.d/uptime-kuma.conf" "${UPTIMEKUMA}/${COPY_WEBSERVER}"
download_local "/etc/systemd/system/uptime-kuma.service" "${UPTIMEKUMA}/${COPY_INIT}"
download_local "/opt/uptime-kuma/docker-compose.yaml" "${UPTIMEKUMA}/${COPY_DOCKER}"

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
