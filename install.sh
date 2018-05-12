# Install script
if [ "$EUID" -ne 0 ]
   then echo "Por favor, ejecuta como root"
   exit
fi

# 1.- Install Fireqos
#################################

# Download and install fireqos
apt-get update
apt-get install iprange ipset
curl https://github.com/firehol/firehol/releases/download/v3.1.5/firehol-3.1.5.tar.bz2 -o /tmp/firehol.tar.bz2
tar xvf /tmp/firehol.tar.bz2
cd /tmp/firehol
./autogen.sh
./configure
make
make install

# Copy fireqos.conf

# Copy files
mkdir -p "/etc/qos"
cp ./interfaces.sh "/etc/qos"
cp ./iptables.sh "/etc/qos"
cp ./services.sh "/etc/qos"

# 2.- Install crontab
(crontab -l ; echo "@reboot /etc/qos/services.sh") | sort - | uniq - | crontab -

# 3. Install netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) 
