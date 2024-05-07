#!/bin/bash

# Update the package list
sudo apt update

# Install Samba
sudo apt install samba -y

# Create a directory to share
sudo mkdir -p /srv/fileshare

# Set permissions on the shared directory
sudo chmod -R 777 /srv/fileshare

# Backup the original Samba configuration file
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# Create a new Samba configuration file
sudo bash -c 'cat <<EOF > /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = File Share Server
   security = user

[fileshare]
   comment = Shared Folder
   path = /srv/fileshare
   browseable = yes
   read only = no
   guest ok = yes
   create mask = 0777
   directory mask = 0777
EOF'

# Restart the Samba service to apply changes
sudo systemctl restart smbd
