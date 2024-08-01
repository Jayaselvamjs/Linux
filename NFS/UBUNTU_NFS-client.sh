#!/bin/bash
#Client
sudo apt update
sudo apt install nfs-common
apt-get instal nfs-utils
#check connection to server 
showmount -e <server_ip>
#Creating Mount Points and Mounting Directories on the Client
mkdir /file_share
mount server_ip:/share_file /file_share
df -h
du -sh /nfs/general
#Mounting the Remote NFS Directories at Boot
sudo nano /etc/fstab
	server_ip:/share_file	    /file_share	   nfs		0		0
#restart NFS
service nfs-kernel-server restart
#Unmounting an NFS Remote Share
sudo umount /nfs/general
df -h