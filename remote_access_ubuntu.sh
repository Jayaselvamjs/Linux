#!/bin/bash
##Method-1----------->It's working only root user
sudo apt-get update
sudo apt-get install xrdp
sudo systemctl enable xrdp
sudo ufw allow from any port 3389 proto tcp
ip address

##Method-2
sudo apt-get install xserver-xorg-core
sudo apt-get install gnome-session-flashback

##Method-3
sudo apt install xrdp
sudo usermod -a -G ssl-cert xrdp
sudo groupadd jsusers
sudo groupadd jsadmins
sudo tee /etc/polkit-1/localauthority/50-local.d/40-allow-colord.pkla <EOT
[Allow colord]
Identity=unix-user:*
Action=org.freedesktop.colour-manager.*
ResultAny=no
ResultInactive=no
ResultActive=yes
EOT

sudo tee ~/.xsessionrc <EOT
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg
EOT
sleep 2
sudo systemctl restart xrdp.service


