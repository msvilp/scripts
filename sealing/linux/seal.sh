#!/bin/sh
#
# Remove node-specific information to allow converting it into a virtual
# machine template.
#
echo "Removing SSH host keys"
rm -f /etc/ssh/ssh_host_*

echo "Removing persistent net rules from udev"
rm -f /etc/udev/rules.d/70-persistent-net.rules

