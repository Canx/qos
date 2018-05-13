# Check we are root
if [ "$(whoami)" != "root" ]; then
    echo "Por favor, ejecuta como root!"
    exit 1
fi

# qos.cfg must be created
if [ ! -f ./qos.cfg ]; then
    echo "qos.cfg no encontrado. Ejecuta config.sh para generarlo."
    exit
fi

# Dependencies
apt-get update
apt-get install autoconf make iprange ipset traceroute ebtables squid bind9

# firehol
git clone https://github.com/firehol/firehol.git /tmp/firehol
cwd=$(pwd)
cd /tmp/firehol
./autogen.sh
./configure --disable-doc --disable-man
make
make install

# interfaces
mv /etc/network/interfaces /etc/network/interfaces.old
cp ./network/interfaces /etc/network/interfaces

# fireqos config
cd $cwd
cp ./firehol/fireqos.conf /usr/local/etc/firehol/

# Bind config
source bind/bind.template
mv /etc/bind/named.conf.options /etc/bind/named.conf.options.old
cp bind/named.conf.options /etc/bind/

# Squid config
source squid/squid.template
mv /etc/squid/squid.conf /etc/squid/squid.conf.old
cp ./squid/squid.conf /etc/squid/

# Config files
mkdir -p "/etc/qos"
cp ./qos.cfg "/etc/qos"
cp ./interfaces.sh "/etc/qos"
cp ./iptables.sh "/etc/qos"
cp ./services.sh "/etc/qos"
cp ./startup.sh "/etc/qos"

# Crontab lines
(crontab -l ; echo "0 0 * * * /usr/sbin/squid -k rotate") | sort - | uniq - | crontab -
(crontab -l ; echo "@reboot /etc/qos/startup.sh") | sort - | uniq - | crontab -

# Netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) 
