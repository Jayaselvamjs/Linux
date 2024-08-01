#!/bin/bash
## Getting Started
sudo apt update && apt upgrade -y
## Install PHP
sudo apt-get install libssh2-1 libssh2-1-dev
sudo apt install php-pear php7.3-ssh2
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt-get install php7.3 php7.3-fpm php7.3-mysql php7.3-cli php7.3-ldap php7.3-zip php7.3-curl php7.3-mbstring php7.3-xmlrpc php7.3-soap php7.3-gd php7.3-xml php7.3-intl php7.3-pear php7.3-bcmath unzip php7.3-json
sudo apt install php7.3 php7.3-mbstring php7.3-xml php7.3-pdo php7.3-gd php7.3-mysql php7.3-json
## After installing all the packages, tweak the PHP settings by editing the file php.ini:
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/max_input_vars = 1000/max_input_vars = 1600/g' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo = 0/g' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/file_uploads = On/file_uploads = On/g' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/g' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/allow_url_fopen = On/allow_url_fopen = On/g' /etc/php/7.3/fpm/php.ini
sudo sed -i 's/date.timezone =/date.timezone = America/Chicago/g' /etc/php/7.3/fpm/php.ini

## Install and Configure Database server for Mantis
sudo apt install mariadb-server mariadb-client
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl status mariadb
## Configure MariaDB Database
mysql -u root -e "CREATE DATABASE mantisdb;"
mysql -u root -e "CREATE USER 'mantis'@'localhost' IDENTIFIED BY 'mentis';"
mysql -u root -e "GRANT ALL PRIVILEGES ON mantisdb.* TO 'mantisuser'@'localhost' IDENTIFIED BY 'Mantis' WITH GRANT OPTION;"
mysql -u root -e "FLUSH PRIVILEGES;"

## Install Nginx
apt-get update -y
sudo apt-get install nginx 

## Download MantisBT
wget https://sourceforge.net/projects/mantisbt/files/mantis-stable/2.24.1/mantisbt-2.24.1.zip
## unzip MantisBT
unzip mantisbt-2.24.1.zip
mv mantisbt-2.24.1 /var/www/html/mantisbt
## set proper permissions and ownership to the mantisbt directory:
chown -R www-data:www-data /var/www/html/mantisbt
chmod -R 755 /var/www/html/mantisbt

## Configure Nginx for MantisBT
sudo tee -i /etc/nginx/sites-available/mantisbt <<EOT
server {
listen 80;
server_name	mantisbt.example.com;
root 		/var/www/html/mantisbt;
index 		index.php;

access_log	/var/log/nginx/example.com.access.log;
error_log 	/var/log/nginx/example.com.error.log;

client_max_body_size 100M;

autoindex 	off;

location / {
index index.html index.php;
try_files $uri /index.php$is_args$args;
}

location ~ \.php$ {
include snippets/fastcgi-php.conf;
fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
include fastcgi_params;
fastcgi_intercept_errors on;
}
}
EOT

## soft link nginx conf file 
ln -s /etc/nginx/sites-available/mantisbt /etc/nginx/sites-enabled/
## check configuration file sync 
nginx -t
##You should get the following output:
##nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
##nginx: configuration file /etc/nginx/nginx.conf test is successful
systemctl restart nginx

## Install Apache Web Server
#sudo apt install apache2 -y
#sudo systemctl status apache2
#sudo systemctl start apache2
#sudo systemctl enable apache2
## Install Mantis BT
#wget https://excellmedia.dl.sourceforge.net/project/mantisbt/mantis-stable/2.22.1/mantisbt-2.22.1.zip
#unzip mantisbt-2.22.1.zip
#sudo mv mantisbt-2.22.1 /var/www/html/mantis/
#sudo chown -R www-data:www-data /var/www/html/mantis
#sudo tee -i /etc/apache2/sites-available/mantis.conf <<EOT
#<VirtualHost *:80>
#    ServerAdmin webmaster@yourdomain.com
#    DocumentRoot "/var/www/html/mantis"
#    ServerName yourdomain.com
#    ServerAlias www.yourdomain.com
#    ErrorLog "/var/log/apache2/mantis-error_log"
#   CustomLog "/var/log/apache2/mantis-access_log" combined
#       <Directory "/var/www/html/mantis/">
#            DirectoryIndex index.php index.html
#            Options FollowSymLinks
#            AllowOverride All
#            Require all granted
#        </Directory>
#</VirtualHost>
#EOT

## soft link nginx conf file 
#ln -s /etc/nginx/sites-available/mantisbt /etc/nginx/sites-enabled/
## restart services
#sudo a2ensite mantis.conf
#sudo systemctl restart apache2

## Configure the Firewall
sudo ufw enable
systemctl status ufw
sudo ufw allow 80

## Access Mantis BT Web Interface
## URL http://yourdomain.com
## localhost/mantis
## Provide a default Mantis BT username "administrator" and password "root"

