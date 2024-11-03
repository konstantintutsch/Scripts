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

# Ping
printf "allow ping: "
firewall-cmd --add-icmp-block-inversion

printf "allow ping reply: "
firewall-cmd --add-icmp-block=echo-reply

printf "allow ping request: "
firewall-cmd --add-icmp-block=echo-request

printf "\n"

# Ports
ports[0]="22/tcp"   # SSH !! IMPORTANT

for port in "${ports[@]}"
do
	printf "add %s: " "$port"
	firewall-cmd --add-port="$port"
done


printf "\nmaking changes permanent: "
firewall-cmd --runtime-to-permanent

printf "reloading: "
firewall-cmd --reload
