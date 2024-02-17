#!/bin/bash

# On Gentoo Linux systems:
#
# /etc/firewalld/firewalld.conf:
# IndividiualCalls=yes
#
# firewall-cmd --reload won't work otherwise

read -p "Are you running this script for the first time? [y/n]: " setup
read -p "Does your system run Docker? [y/n]: " docker

# Get interface for setup
if [[ "$setup" == "y" ]]
then
    ip addr
    read -p "Which interface does your system use? [eth0/enp2s0/…]: " interface

    printf "Adding interface to zone: "
    firewall-cmd --zone=public --add-interface="$1"

    printf "Selecting default zone: "
    firewall-cmd --set-default-zone=public

    printf "Allowing ping:\n"
    firewall-cmd --add-icmp-block-inversion
    firewall-cmd --add-icmp-block=echo-reply
    firewall-cmd --add-icmp-block=echo-request
else
    printf "Skipping setup …\n"
fi

if [[ "$docker" == "y" ]]
then
    printf "Stopping Docker …\n"
    systemctl stop docker

    printf "Disabeling iptables usage in Docker …\n"
    echo '{
"iptables": false
}' > /etc/docker/daemon.json

    printf "Adding Docker compatibility to FirewallD configuration …\n"
    firewall-cmd --zone=public --add-masquerade
      
    printf "Starting Docker …\n"
    systemctl start docker
else
    printf "Skipping Docker compatibility setup …\n"
fi

# Close current open ports
OPEN_PORTS="$(firewall-cmd --list-ports)"
for PORT in $OPEN_PORTS
do
	printf "Remove %s: " "$PORT"
	firewall-cmd --remove-port="$PORT"
done

# Open new ports
PORTS[0]="22/tcp"    # SSH !! IMPORTANT

for PORT in "${PORTS[@]}"
do
	printf "Add %s: " "$PORT"
	firewall-cmd --add-port="$PORT"
done

printf "Making changes permanent: "
firewall-cmd --runtime-to-permanent

printf "Reloading: "
firewall-cmd --reload
