#!/bin/bash
#updating the package registry
sudo apt update

#Install Samba
sudo apt install samba -y

#Verify the installation
whereis samba
samba -V

#confirm that Samba is running
systemctl status smbd

##Create a Shared Directory
sudo mkdir /sambashare
ls /

##Configure Samba’s Global Options
sudo sed -i 's|workgroup = .*|workgroup = WORKGROUP|g' /etc/samba/smb.conf
sudo sed -i 's|server string = .*|server string = samba_server|g' /etc/samba/smb.conf
#Networking
sudo sed -i 's|interfaces = .*|interfaces = lo enp0s3|g' /etc/samba/smb.conf
sudo sed -i 's|bind interfaces only = .*|bind interfaces only = yes|g' /etc/samba/smb.conf
#Debugging
sudo sed -i 's|log file = .*|log file = /var/log/samba/log.%m|g' /etc/samba/smb.conf
sudo sed -i 's|max log size = .*|max log size = 1000|g' /etc/samba/smb.conf
sudo sed -i 's|logging = .*|logging = file|g' /etc/samba/smb.conf
sudo sed -i 's|panic action = .*|panic action = /usr/share/samba/panic-action %d|g' /etc/samba/smb.conf
#Authentication, Domain, and Misc
sudo sed -i 's|server role = .*|server role = standalone server|g' /etc/samba/smb.conf
sudo sed -i 's|obey pam restrictions = .*|obey pam restrictions = yes|g' /etc/samba/smb.conf
sudo sed -i 's|unix password sync = .*|unix password sync = yes|g' /etc/samba/smb.conf
sudo sed -i 's|passwd program = .*|passwd program = /usr/bin/passwd %u|g' /etc/samba/smb.conf
#sudo sed -i 's|passwd chat = .*|passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* ./g' /etc/samba/smb.conf
#sudo sed -i 's|passwd chat = .*|passwd chat = *Enter\\snew\\s*\\spassword:* %n\\n *Retype\\snew\\s*\\spassword:* %n\\n *password\\supdated\\ssuccessfully* .\\//g' /home/js/test/smb.conf
sudo sed -i 's|map to guest = .*|#map to guest = bad user|g' /etc/samba/smb.conf
sudo sed -i 's|usershare allow guests = .*|usershare allow guests = yes|g' /etc/samba/smb.conf

#check for syntax errors
testparm

##Set Up a User Account
#sudo smbpasswd -a username
sudo adduser samba_user
sudo smbpasswd -a samba_user

#To grant read, write, and execute permissions to the sharing directory, run setfacl:
sudo setfacl -R -m "u:new_user:rwx" /sambashare

##Configure Samba Share Directory Settings
#Access the configuration file once again to add the previously made sharing directory. Go to the end of the file and add:
echo -e "\n[sharing]\ncomment = Samba share directory\npath = /sambashare\nread only = no\nwritable = yes\nbrowseable = yes\nguest ok = no\nvalid users = @samba_user" | sudo tee -a /etc/samba/smb.conf
#sudo tee /etc/samba/smb.conf <<EOT
#[sharing]
#comment = Samba share directory
#path = /home/sambashare
#read only = no
#ritable = yes
#browseable = yes
#guest ok = no
#valid users = @new_user
#EOT

##Update the Firewall Rules
sudo ufw allow samba
sudo systemctl restart smbd

#smb://ip-address/sharing