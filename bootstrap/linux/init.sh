#!/bin/sh
#
# Prepare node for a Puppet run and then run Puppet.
#
# Usage examples:
#
# OS=jessie FQDN=test1.domain.com STATIC_IP=true IP=192.168.15.110 ./init.sh
# OS=trusty FQDN=test2.domain.com ./init.sh
# OS=jessie FQDN=test3.acme.com ./init.sh
#
#

### PREPARATIONS
PATH=/bin:/usr/bin:/sbin:/usr/sbin

# Verify that FQDN is set
if [ "$FQDN" = "" ]; then
    echo "ERROR: FQDN not defined!"
    exit 1
fi
HOSTNAME=`echo $FQDN|cut -d "." -f 1`
DOMAIN=`echo $FQDN|cut -d "." -f 2-`

# Temporary files will go to the home directory
cd ~

# Load site configuration
. ./init.conf
if [ $? -ne 0 ]; then
    echo "ERROR: init.conf missing!"
    exit 1
fi

### BASIC SETUP

# Install sudo, if it is not present
which sudo
if [ $? -ne 0 ]; then
    apt-get install sudo
fi

# Regenerate SSH host keys if they do not exist. This is useful with cloned VMs and harmless on others.
test -f /etc/ssh/ssh_host_dsa_key || sudo /usr/sbin/dpkg-reconfigure openssh-server

# Set hostname/fqdn. Simply doing a "sudo echo" does not seem to work, hence the 
# trickery.
sudo hostname $FQDN
echo $FQDN|sudo tee /etc/hostname > /dev/null

HOSTS_LINE="$IP $FQDN $HOSTNAME"

# Remove previous localhost entry
sudo sed -i '/127.0.1.1/d' /etc/hosts
grep "$HOSTS_LINE" /etc/hosts
if [ $? -ne 0 ]; then
    echo "$HOSTS_LINE"|sudo tee -a /etc/hosts > /dev/null
fi

### STATIC NETWORK SETUP
if [ "$USE_STATIC_IP" = "true" ]; then

# Get the node's IP based on FQDN from DNS, if it has not been explicitly set
if [ "$IP" = "" ]; then
    IP=`dig +short $FQDN`
    if [ "$IP" = "" ]; then
        echo "ERROR: IP not defined nor found from DNS!"
        exit 1
    else
        echo "NOTICE: Found A record $IP for $FQDN from DNS"
    fi
fi

# Setup /etc/resolv.conf
sudo cp -n /etc/resolv.conf /etc/resolv.conf.dist
sudo cat > /etc/resolv.conf << EOF

domain $DOMAIN
search $DOMAIN
nameserver $NAMESERVER
EOF

# Setup /etc/network/interfaces
IFF="/etc/network/interfaces"
sudo cp -n $IFF $IFF.dist
sudo cat > $IFF << EOF

auto lo $IFACE
iface lo inet loopback
iface $IFACE inet static
    address $IP
    netmask $NETMASK
    gateway $GATEWAY
    broadcast $BROADCAST
EOF
fi

### PUPPET SETUP

if [ "$USE_PUPPETLABS_REPOS" = "true" ]; then
    wget https://apt.puppetlabs.com/puppetlabs-release-$OS.deb
    sudo dpkg -i puppetlabs-release-$OS.deb
    sudo apt-get update
fi

sudo apt-get -y install puppet facter

PUPPETCONF="/etc/puppet/puppet.conf"
sudo cp -n $PUPPETCONF $PUPPETCONF.dist
sudo cat > $PUPPETCONF << EOF
[main]
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
stringify_facts=true

[agent]
environment=production
server=$PUPPETMASTER
pluginsync=true
EOF


# Run Puppet
sudo puppet agent --enable
sudo puppet agent --test --waitforcert 30

# Install security updates
sudo apt-get update && apt-get dist-upgrade -y

# Reboot unless prevented by the user
echo
echo "Press return to reboot the node or CTRL-C to cancel."
read reboot
sudo shutdown -r now
