#!/bin/bash
#install NFS-server
sudo apt update
sudo apt install nfs-kernel-server
#Creating the Share Directories on the Host
mkdir /share_file
sudo chown nobody:nogroup /share_file
#Configuring the NFS Exports on the Host Server
sudo echo "/share_file 	client_ip(rw,sync,no_subtree_check)" >> /etc/exports
#reload exportfs	
exportfs -v
#restart NFS
service nfs-kernel-server restart
#Adjusting the Firewall on the Host
sudo ufw status
sudo ufw allow from client_ip to any port nfs
sudo ufw status
