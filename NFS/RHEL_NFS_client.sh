#!/bin/bash
#Install NFS on Client
sudo dnf update
sudo dnf install rpcbind nfs-utils -y
sudo systemctl enable rpcbind
sudo systemctl status rpcbind
#create a mount point for the NFS share
sudo mkdir -p /nfs/imports/myshare
#mount the NFS volume
sudo mount -t nfs Server IP:/tmp/my_nfsshare  /nfs/imports/myshare/
#permanent and automatic process by adding the NFS volume to the client
echo "server IP:/tmp/my_nfsshare  /nfs/imports/myshare/  nfs  defaults 0 0" >> /etc/fstab
#NFS volume is mounted with the mount command
sudo mount | grep -i nfs
server IP:/tmp/my_nfsshare on /nfs/imports/myshare


