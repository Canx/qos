# Check we are root
if [ "$EUID" -ne 0 ]
   then echo "Por favor, ejecuta como root"
   exit
fi

# Config basic parameters
source ./config.sh

# Download and install needed packages
apt-get update
apt-get install autoconf make iprange ipset traceroute ebtables squid bind9

# Install firehol
git clone https://github.com/firehol/firehol.git /tmp/firehol
cwd=$(pwd)
cd /tmp/firehol
./autogen.sh
./configure --disable-doc --disable-man
make
make install

# Copy fireqos.conf
cd $cwd
cp ./firehol/fireqos.conf /usr/local/etc/firehol/

# TODO: Copy squid and bind9 config


# Copy config files
mkdir -p "/etc/qos"
cp ./qos.cfg "/etc/qos"
cp ./interfaces.sh "/etc/qos"
cp ./iptables.sh "/etc/qos"
cp ./services.sh "/etc/qos"
cp ./startup.sh "/etc/qos"

# 2.- Install crontab line
(crontab -l ; echo "@reboot /etc/qos/startup.sh") | sort - | uniq - | crontab -

# 3. Install netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) 
