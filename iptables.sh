source ./config.cfg

# PARTE 2: Reglas IPTABLES
IPT=/sbin/iptables
EBT=/sbin/ebtables


# Activamos el forwarding
sysctl net.ipv4.ip_forward=1

# Limpiamos todas las reglas
$IPT -t nat -F
$IPT -t mangle -F
$IPT -F
$IPT -X

# Marca de tráfico bulk
$IPT -t mangle -X BULKCONN
$IPT -t mangle -N BULKCONN
$IPT -t mangle -F BULKCONN
$IPT -t mangle -A BULKCONN -m mark ! --mark 0 -j ACCEPT
$IPT -t mangle -A BULKCONN -m length --length 0:500 -j RETURN
$IPT -t mangle -A BULKCONN -m connbytes --connbytes 0:250 --connbytes-dir both --connbytes-mode avgpkt -j RETURN
$IPT -t mangle -A BULKCONN -m connbytes --connbytes 5048576: --connbytes-dir both --connbytes-mode bytes -j MARK --set-xmark 0x8/0x8
$IPT -t mangle -A BULKCONN -j RETURN

# Marca de tráfico youtube
$IPT -t mangle -X YOUTUBE
$IPT -t mangle -N YOUTUBE
$IPT -t mangle -F YOUTUBE
# Descomentar si no quieres que vaya Youtube
#$IPT -t mangle -A YOUTUBE -o br1 -m ndpi --youtube -j DROP
$IPT -t mangle -A YOUTUBE -m mark ! --mark 0 -j ACCEPT
#$IPT -t mangle -A YOUTUBE -o br1 -m ndpi --youtube -j MARK --set-mark 0xF
$IPT -t mangle -F POSTROUTING

$IPT -A POSTROUTING -t mangle -o br1 -j CONNMARK --restore-mark

#$IPT -A POSTROUTING -t mangle -o br1 -j YOUTUBE
$IPT -A POSTROUTING -t mangle -o br1 -j BULKCONN
$IPT -A POSTROUTING -t mangle -o br1 -j CONNMARK --save-mark


# Marca de puertos (no funciona al estar en otro bridge, creo)

#iptables -A PREROUTING -t mangle -j CONNMARK --restore-mark

#$IPT -A FORWARD -t mangle -m physdev --physdev-in enp13s0f0 -j MARK --set-xmark 0x1/0x1
#$IPT -A FORWARD -t mangle -m physdev --physdev-in enp13s0f1 -j MARK --set-xmark 0x2/0x2
#iptables -A PREROUTING -t mangle -m physdev --physdev-out enp13s0f0 -j CONNMARK --set-mark 1
#iptables -A PREROUTING -t mangle -m physdev --physdev-out enp13s0f1 -j CONNMARK --set-mark 2

#iptables -A POSTROUTING -t mangle -j CONNMARK --save-mark


### Activamos EBTABLES
#/sbin/rmmod br_netfilter
/sbin/modprobe br_netfilter
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.bridge.bridge-nf-call-arptables=1
sysctl net.bridge.bridge-nf-call-ip6tables=1

$EBT -t broute -F
$EBT -t nat -F
$EBT -t filter -F
# Enrutamos el tráfico DNS y HTTP que viene de la LAN, el resto puenteado.
$EBT -t broute -A BROUTING -i br0 -p IPv4 --ip-protocol 17 --ip-destination-port 53 -j redirect --redirect-target DROP
$EBT -t broute -A BROUTING -i br0 -p IPv4 --ip-protocol 6 --ip-destination-port 80 -j redirect --redirect-target DROP

# Enrutamos al router el tráfico DNS tanto de un lado como del otro, de los puertos LAN
for interface in "${LAN[@]}"
do
    $IPT -t nat -A PREROUTING -m physdev --physdev-in $interface -p udp --dport 53 -j DNAT --to $IP
done
$IPT -t nat -A PREROUTING -m physdev --physdev-in veth1 -p udp --dport 53 -j DNAT --to $IP

# Redirigimos el tráfico de salida al Squid de los puertos LAN (parece que no es necesario el de entrada)
for interface in "${LAN[@]}"
do
    $IPT -t nat -A PREROUTING -m physdev --physdev-in $interface -p tcp --dport 80 -j DNAT --to $IP:3128
done

########## LOGS ###############################

# Log rules for BULKCONN
#$IPT -t mangle -A BULKCONN -j LOG --log-prefix "BULKCONN:BULK:" --log-level 6

# Log rules for DNS
#$EBT -t broute -I BROUTING -p IPv4 --ip-protocol 17 --ip-destination-port 53 --log-level debug --log-ip --log-arp --log-prefix "EBT BROUTE BROUTING (DNS):" -j CONTINUE
#$EBT -t nat -I PREROUTING -p IPv4 --ip-protocol 17 --ip-destination-port 53 --log-level debug --log-ip --log-arp --log-prefix "EBT NAT PREROUTING (DNS):" -j CONTINUE
#$EBT -t filter -I FORWARD -p IPv4 --ip-protocol 17 --ip-destination-port 53 --log-level debug --log-ip --log-arp --log-prefix "EBT FILTER FORWARD (DNS):" -j CONTINUE
#$EBT -t filter -I INPUT -p IPv4 --ip-protocol 17 --ip-destination-port 53 --log-level debug --log-ip --log-arp --log-prefix "EBT FILTER INPUT (DNS):" -j CONTINUE
#$EBT -t filter -I INPUT -p IPv4 --ip-protocol 17 --ip-destination-port 53 --log-level debug --log-ip --log-arp --log-prefix "EBT FILTER INPUT (DNS):" -j CONTINUE
#$IPT -I OUTPUT -p udp --dport 53 -j LOG --log-prefix "IPT FILTER OUTPUT (DNS):" --log-level debug
#$IPT -I INPUT -j LOG -p udp --dport 53 --log-prefix "IPT FILTER INPUT (DNS):" --log-level debug
#$IPT -I FORWARD -p udp --dport 53 -j LOG --log-prefix "IPT FILTER FORWARD (DNS):" --log-level debug
#$IPT -I PREROUTING -t nat -p udp --dport 53 -j LOG --log-prefix "IPT NAT PREROUTING (DNS):" --log-level debug
#$IPT -I POSTROUTING -t nat -p udp --dport 53 -j LOG --log-prefix "IPT NAT POSTROUTING (DNS):" --log-level debug
# Log rules for HTTP
#$EBT -t broute -I BROUTING -p IPv4 --ip-protocol 6 --ip-destination-port 80 --log-level debug --log-ip --log-arp --log-prefix "EBT BROUTE BROUTING (HTTP):" -j CONTINUE
#$EBT -t nat -I PREROUTING -p IPv4 --ip-protocol 6 --ip-destination-port 80 --log-level debug --log-ip --log-arp --log-prefix "EBT NAT PREROUTING (HTTP):" -j CONTINUE
#$EBT -t filter -I FORWARD -p IPv4 --ip-protocol 6 --ip-destination-port 80 --log-level debug --log-ip --log-arp --log-prefix "EBT FILTER FORWARD (HTTP):" -j CONTINUE
#$EBT -t filter -I INPUT -p IPv4 --ip-protocol 6 --ip-destination-port 80 --log-level debug --log-ip --log-arp --log-prefix "EBT FILTER INPUT (HTTP):" -j CONTINUE
#$EBT -t filter -I INPUT -p IPv4 --ip-protocol 6 --ip-destination-port 80 --log-level debug --log-ip --log-arp --log-prefix "EBT FILTER INPUT (HTTP):" -j CONTINUE
#$IPT -I OUTPUT -p tcp --dport 80 -j LOG --log-prefix "IPT FILTER OUTPUT (HTTP):" --log-level debug
#$IPT -I INPUT -j LOG -p tcp --dport 80 --log-prefix "IPT FILTER INPUT (HTTP):" --log-level debug
#$IPT -I FORWARD -p tcp --dport 80 -j LOG --log-prefix "IPT FILTER FORWARD (HTTP):" --log-level debug
#$IPT -I PREROUTING -t nat -p tcp --dport 80 -j LOG --log-prefix "IPT NAT PREROUTING (HTTP):" --log-level debug
#$IPT -I POSTROUTING -t nat -p tcp --dport 80 -j LOG --log-prefix "IPT NAT POSTROUTING (HTTP):" --log-level debug
