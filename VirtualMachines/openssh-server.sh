#!/bin/bash

# let update first
sudo apt-get update

# first lets try to downloadthe ssh and ufw first
sudo apt-get install openssh-server ufw

# then let change theport to something like 3535
echo "Port 3535" >> /etc/ssh/sshd-config.conf

# let start the ufw
sudo ufw enable
# allow our port
sudo ufw allow 3535

#start our ssh service
sudo systemctl start ssh
