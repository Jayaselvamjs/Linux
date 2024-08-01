#!/bin/bash
#Install NFS on Server
sudo dnf update
sudo dnf install rpcbind nfs-utils -y

sudo systemctl enable --now nfs-server
sudo systemctl status nfs-server
#Create an NFS Share Directory
mkdir -p /tmp/my_nfsshare
#Export an NFS Share Directory
echo "/tmp/my_nfsshare server-ip/24(rw,no_root_squash)" > /etc/exports
#Set ownership
sudo chown nobody:nobody /tmp/my_nfsshare
sudo chmod 775 /tmp/my_nfsshare
#Export the exports
sudo exportfs -rv
#Configure your firewall
sudo firewall-cmd --add-service nfs --permanent
sudo firewall-cmd --permanent --add-service={nfs,rpc-bind,mountd}
sudo firewall-cmd --permanent --add-service={nfs,rpc-bind,mountd}
#NFS service restart
sudo systemctl restart nfs-server
sudo systemctl status nfs-server