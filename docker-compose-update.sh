#!/bin/bash

base="/opt"
apps=$(find ${base} -mindepth 1 -maxdepth 1 -type d -print)

function update_docker {
    local -
    set -x

    if [[ -z $1 ]]
    then
        echo "No app passed to be updated."

        return 1
    fi

    app=${1}

    cd "$app" || return 1

    if [[ $app == *"anki"* ]]
    then
        cd build || return 1
        git pull || return 1
        cd docs/syncserver || return 1

        printf "Latest version: "
        curl -v https://github.com/ankitects/anki/releases/latest 2>&1 | grep "location"

        read -p "Anki version: " anki_version || return 1

        docker build -f Dockerfile --no-cache --build-arg ANKI_VERSION="${anki_version}" -t anki-sync-server . || return 1
        cd ../../../ || return 1
    fi

    docker-compose pull || return 1
    docker-compose up --force-recreate --detach || return 1

    if [[ $app == *"davis"* ]]
    then
        docker compose exec -it davis sh -c "APP_ENV=prod bin/console doctrine:migrations:migrate --no-interaction" || return 1
    fi
}

PS3="Update (-1 to finish, -2 for all, -3 to cancel): "

selected=()
select app in ${apps[@]}
do
    if [[ $REPLY == -1 ]]
    then
        break
    elif [[ $REPLY == -2 ]]
    then
        selected=$apps

        break
    elif [[ $REPLY == -3 ]]
    then
        selected=()

        break
    else
        selected+=(${app})
    fi

    echo "Queued:"
    for selection in ${selected[@]}
    do
        echo "- $selection"
    done
done

for app in ${selected[@]}
do
    if ! update_docker "$app"
    then
        echo "---"
        echo "Ein Fehler ist beim Update von ${app} aufgetreten"
        echo "Host: ${HOSTNAME}"
        echo "Zeit: $(date)"
        read -p "Unterbrochen. Mit Enter weitermachen." interrupt
    fi
done

if [[ -n $selected ]]
then
    docker image prune --force
fi
