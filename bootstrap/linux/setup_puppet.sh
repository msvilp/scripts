#!/bin/bash
#
# Setup Puppet on the node and do the first run

PATH=/bin:/usr/bin/

# Arguments from Vagrant
LSBDISTCODENAME=$1
FQDN=$2
HOST=`echo $FQDN|cut -d "." -f 1`

# Install Puppet
cd ~
wget https://apt.puppetlabs.com/puppetlabs-release-$LSBDISTCODENAME.deb
sudo dpkg -i puppetlabs-release-$LSBDISTCODENAME.deb
sudo apt-get update
sudo apt-get -y install puppet facter

# Set hostname/fqdn. Simply doing a "sudo echo" does not seem to work, hence the 
# trickery.
sudo hostname $FQDN
echo $FQDN|sudo tee /etc/hostname > /dev/null
echo "127.0.1.1 $FQDN $HOST"|sudo tee -a /etc/hosts > /dev/null

# Setup puppet.conf
if [ -r "/vagrant/puppet.conf" ]; then
    sudo cp /etc/puppet/puppet.conf /etc/puppet/puppet.conf.dist
    sudo cp /vagrant/puppet.conf /etc/puppet/puppet.conf
fi

# Run Puppet
puppet agent --test --waitforcert 60

# Install security updates
apt-get update && apt-get dist-upgrade -y
