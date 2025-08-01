#!/bin/bash

# Exit on error
set -e
trap "{ notify-send --urgency=critical '🔴 Server Backup Failed' 'An error occured.'; }" ERR

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
    mkdir -p "${BACKUP_DIRECTORY}/$(dirname $4)"
    scp "$2"@"$1":"$3" "${BACKUP_DIRECTORY}/$4"
}

downloadlocal() {
    download "$LOCAL" "konstantin" "$1" "${LOCAL}/$2"
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
# UMAMI_DB_NAME
# UMAMI_DB_USER
# UMAMI_DB_PASSWORD

ssh "konstantin"@"$LOCAL" "mariadb-dump -u${UMAMI_DB_USER} -p${UMAMI_DB_PASSWORD} ${UMAMI_DB_NAME} > ${UMAMI_DB}"
downloadlocal "${UMAMI_DB}" "${UMAMI}/${COPY_DATABASE}"
ssh "konstantin"@"$LOCAL" "rm ${UMAMI_DB}"
downloadlocal "/etc/httpd/conf.d/umami.conf" "${UMAMI}/${COPY_WEBSERVER}"
downloadlocal "/etc/systemd/system/umami.service" "${UMAMI}/${COPY_INIT}"

#
# Websites
#

WEBSERVER="httpd"

downloadlocal "/etc/httpd/conf.d/base.conf" "${WEBSERVER}/base.conf"

downloadlocal "/etc/httpd/conf.d/konstantintutsch.com.conf" "${WEBSERVER}/konstantintutsch.com.conf"
downloadlocal "/etc/httpd/conf.d/konstantintutsch.de.conf" "${WEBSERVER}/konstantintutsch.de.conf"
downloadlocal "/etc/httpd/conf.d/apps.conf" "${WEBSERVER}/apps.conf"

#
# Syncthing
#

download "$LOCAL" "syncthing" "/home/syncthing/.local/state/syncthing/config.xml" "${LOCAL}/syncthing.xml"

#
# Conduit
#

CONDUIT="conduit"

downloadlocal "/etc/systemd/system/conduit.service" "${CONDUIT}/${COPY_INIT}"
downloadlocal "/etc/httpd/conf.d/conduit.conf" "${CONDUIT}/${COPY_WEBSERVER}"
download "$LOCAL" "conduit" "/home/conduit/download.sh" "${LOCAL}/${CONDUIT}/download.sh"
download "$LOCAL" "conduit" "/home/conduit/config.toml" "${LOCAL}/${CONDUIT}/config.toml"
rsync --verbose --archive --recursive --delete "conduit"@"$LOCAL":"/home/conduit/database" "${BACKUP_DIRECTORY}/${LOCAL}/${CONDUIT}/directory"

#
# PHP
#

downloadlocal "/etc/php.ini" "${SABREDAV}/php/php.ini"
downloadlocal "/etc/php.d/10-opcache.ini" "${SABREDAV}/php/php.10-opcache.ini"

downloadlocal "/etc/php-fpm.conf" "${SABREDAV}/php/php-fpm.conf"
downloadlocal "/etc/php-fpm.d/www.conf" "${SABREDAV}/php/php-fpm.www.conf"

#
# System
#

DNF="dnf"
FAIL2BAN="fail2ban"

downloadlocal "~/firewalld.sh" "firewalld.sh"
downloadlocal "/etc/dnf/automatic.conf" "${DNF}/automatic.conf"
downloadlocal "~/dnfmail.sh" "${DNF}/dnfmail.sh"

#
# Success
#

if [[ "$1" != "force" ]]
then
    touch "$SAVE"
fi

notify-send --urgency=normal "🟢 Server Backup Success" "All data backed up."
