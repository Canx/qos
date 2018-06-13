#!/bin/bash
read -p "Quieres generar archivo de configuración (s/n)?" -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]
then
echo "Interfaces de red:"
ip -o link show | awk -F': ' '{print $2}'

echo "Indica el interfaz WAN de los disponibles:"
read WAN
[[ -z "$WAN" ]] && { echo "Debes indicar el interfaz WAN!" ; exit; }

echo "Indica una lista de interfaces LAN separados por espacio. Por ejemplo, eth0 eth1 eth2:"
read LAN
[[ -z "$LAN" ]] && { echo "Debes indicar el/los interfaces LAN!" ; exit; }

echo "Indica el ancho de banda de descarga en megabits (85% al 95% del total):"
read DOWNLOAD
[[ -z "$DOWNLOAD" ]] && { echo "Debes indicar el el ancho de banda de descarga!" ; exit; }

echo "Indica el ancho de banda de subida en megabits (85% al 95% del total):"
read UPLOAD 
[[ -z "$UPLOAD" ]] && { echo "Debes indicar el el ancho de banda de subida!" ; exit; }

echo "Indica una lista de servidores DNS separados por espacio. Por ejemplo, 172.27.111.5 172.27.111.6:"
read DNS
[[ -z "$DNS" ]] && { echo "Debes indicar el/los servidores DNS!" ; exit; }

echo "Indica la IP de administración del servidor:"
read IP
[[ -z "$IP" ]] && { echo "Debes indicar la IP de administración!" ; exit; }

echo "Indica la máscara en formato númerico de la IP:"
read MASK
[[ -z "$MASK" ]] && { echo "Debes indicar la máscara de la ip!" ; exit; }

echo "Indica la IP de la puerta de enlace:"
read GATEWAY
[[ -z "$GATEWAY" ]] && { echo "Debes indicar la ip de la puerta de enlace!" ; exit; }

echo "Indica la memoria disponible para cache (en MB):"
read CACHEMEM
[[ -z "$CACHEMEM" ]] && { echo "Debes indicar la cantidad de memoria para cache!" ; exit; }

echo "WAN=$WAN" > ./qos.cfg
echo "LAN=($LAN)" >> ./qos.cfg
echo "UPLOAD=$UPLOAD" >> ./qos.cfg
echo "DOWNLOAD=$DOWNLOAD" >> ./qos.cfg
echo "DNS=($DNS)" >> ./qos.cfg
echo "IP=$IP" >> ./qos.cfg
echo "MASK=$MASK" >> ./qos.cfg
echo "GATEWAY=$GATEWAY" >> ./qos.cfg
echo "CACHEMEM=$CACHEMEM" >> ./qos.cfg

echo "Fichero qos.conf generado! Revísalo antes de ejecutar install.sh"
fi

# Generando archivos de configuración
if [ ! -f ./qos.cfg ]; then
    echo "qos.cfg no encontrado. Ejecuta config.sh para generarlo."
    exit
fi

# Generate config files
source ./bind/bind.template
source ./squid/squid.template
