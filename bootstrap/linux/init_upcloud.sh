#!/bin/sh
#
# Prepare UpCloud virtualserver for a Puppet run and then run Puppet.
#
# REQUIRES: $PUPPETMASTER variable in init.conf
#

. ./init.conf

### PREPARATIONS
PATH=/bin:/usr/bin:/sbin:/usr/sbin
OS=$(lsb_release -cs)

FQDN=`hostname -f`
HOSTNAME=`hostname -s`
DOMAIN=`hostname -d`

# Temporary files will go to the home directory
cd ~

### BASIC SETUP

# Install sudo, if it is not present
which sudo
if [ $? -ne 0 ]; then
    apt-get install sudo
fi

IP=$(ifconfig eth0 | grep "inet " | awk -F'[: ]+' '{ print $4 }')

HOSTS_LINE="$IP $FQDN $HOSTNAME"

# Remove previous localhost entry
sudo sed -i '/127.0.1.1/d' /etc/hosts
grep "$HOSTS_LINE" /etc/hosts
if [ $? -ne 0 ]; then
    echo "$HOSTS_LINE"|sudo tee -a /etc/hosts > /dev/null
fi

### PUPPET SETUP

wget https://apt.puppetlabs.com/puppetlabs-release-$OS.deb
sudo dpkg -i puppetlabs-release-$OS.deb
sudo apt-get update

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
