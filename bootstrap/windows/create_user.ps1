### Create the "vagrant" user and add it to the local administrator group
net user vagrant "password" /ADD
net localgroup administrators vagrant /add
