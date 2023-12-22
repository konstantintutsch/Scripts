#!/bin/bash

# /etc/firewalld/firewalld.conf: IndividiualCalls=yes
# firewall-cmd --reload won't work otherwise

printf "set default zone to drop:\n"
firewall-cmd --set-default-zone=drop
printf "\n"


open_ports="$(firewall-cmd --list-ports)"
for open_port in $open_ports
do
	printf "remove %s: " "$open_port"
	firewall-cmd --remove-port="$open_port"
done
printf "\n"


# Ports
ports[0]="22/tcp"   # SSH !! IMPORTANT
ports[1]="22000/tcp" # Syncthing
ports[2]="21027/udp" # Syncthing
ports[3]="22000/udp" # Syncthing
ports[4]="53317/udp" # LocalSend Multicast
ports[5]="53317/tcp" # LocalSend
ports[6]="8000/tcp"  # $ jekyll serve (test website on different devices and browsers)

for port in "${ports[@]}"
do
	printf "add %s: " "$port"
	firewall-cmd --add-port="$port"
done


printf "\nmaking changes permanent: "
firewall-cmd --runtime-to-permanent

printf "reloading: "
firewall-cmd --reload
