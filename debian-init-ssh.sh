#!/bin/bash

 cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Generate a new sources.list file with network sources
 echo "deb http://deb.debian.org/debian/ $(lsb_release -cs) main" > /etc/apt/sources.list
 echo "deb-src http://deb.debian.org/debian/ $(lsb_release -cs) main" >> /etc/apt/sources.list
 echo "deb http://deb.debian.org/debian/ $(lsb_release -cs)-updates main" >> /etc/apt/sources.list
 echo "deb-src http://deb.debian.org/debian/ $(lsb_release -cs)-updates main" >> /etc/apt/sources.list
 echo "deb http://security.debian.org/debian-security/ $(lsb_release -cs)/updates main" >> /etc/apt/sources.list
 echo "deb-src http://security.debian.org/debian-security/ $(lsb_release -cs)/updates main" >> /etc/apt/sources.list

# Update the package lists
 apt update -y
 apt install sudo -y

# Print the updated sources.list file

cat /etc/apt/sources.list

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Backup the original sshd_config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modify sshd_config to allow remote root login
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Reload the SSH service
systemctl reload sshd

echo "SSH Remote root login enabled. "
echo "/etc/apt/sources.list is update. "

