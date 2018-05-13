#!/bin/bash

source ./config.cfg

######################################################
#
# 1. Creamos los puentes y añadimos los interfaces
ip link add name br0 type bridge
for interface in "${LAN[@]}"
do
    ip link set $interface up
    ip link set $interface master br0
done

ip link add name br1 type bridge
ip link set $WAN up
ip link set $WAN master br1

# 2. Conectamos los puentes con un interfaz virtual
ip link add dev veth1 type veth peer name veth2
ip link set veth1 up
ip link set veth1 master br0

ip link set veth2 up
ip link set veth2 master br1

# 3. Levantamos los puentes
ip link set br0 up
ip link set br1 up
ip a a $IP/$MASK dev br0

ip route add default via $GATEWAY

# 4. Configuramos los DNS
for server in "${DNS[@]}"
do 
    echo "nameserver $server" > /etc/resolv.conf
done
