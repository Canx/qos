# Install script
if [ "$EUID" -ne 0 ]
   then echo "Por favor, ejecuta como root"
   exit
fi

# 1.- Install Fireqos
#################################

# Download and install fireqos
apt-get update
apt-get install autoconf make iprange ipset traceroute ebtables
git clone https://github.com/firehol/firehol.git /tmp/firehol
cd /tmp/firehol
./autogen.sh
./configure --disable-doc --disable-man
make
make install

# Copy fireqos.conf
cp ./fireqol.conf /usr/local/etc/firehol/

# Copy files
mkdir -p "/etc/qos"
cp ./qos.cfg "etc/qos"
cp ./interfaces.sh "/etc/qos"
cp ./iptables.sh "/etc/qos"
cp ./services.sh "/etc/qos"

# 2.- Install crontab
(crontab -l ; echo "@reboot /etc/qos/services.sh") | sort - | uniq - | crontab -

# 3. Install netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) 
