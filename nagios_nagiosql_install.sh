#!/bin/bash
echo #####################################################
echo "start installing Prerequisites"
echo #####################################################
sudo apt update && sudo apt upgrade
sudo apt install -y wget build-essential apache2 openssl perl make libgd-dev libperl-dev libssl-dev daemon autoconf libc6-dev libmcrypt-dev libnet-snmp-perl gettext unzip curl
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install -y gcc-11 g++-11

sudo apt install -y wget build-essential apache2 php-7.3 libapache2-mod-php7.3 openssl perl make php-7.3-gd libgd-dev libperl-dev libssl-dev daemon autoconf libc6-dev libmcrypt-dev libnet-snmp-perl gettext unzip curl
sudo apt install -y wget build-essential apache2 php-7.3 openssl perl make php-7.3-gd libgd-dev libapache2-mod-php7.3 libperl-dev libssl-dev daemon autoconf libc6-dev libmcrypt-dev libssl-dev libnet-snmp-perl gettext unzip
sudo apt install wget unzip curl openssl build-essential libgd-dev libssl-dev libapache2-mod-php7.3 php7.3-gd php-7.3 apache2 -y
sudo apt install autoconf gcc make unzip libgd-dev libmcrypt-dev libssl-dev dc snmp libnet-snmp-perl gettext
sudo apt install gnutls-bin libgnutls30 libgnutls-dane0 libgnutls28-dev libgnutlsxx28 libgnutls-openssl27 libgnutls28
sudo cpan install DBI
sudo apt install libtap-formatter-junit-perl libtap-harness-archive-perl libtap-parser-sourcehandler-pgtap-perl
echo #####################################################
echo installed Prerequisites
echo ########################################################################################################################
echo 'start installing NAGIOS' 
echo ########################################################################################################################
echo "Download Nagios 4 Download the latest stable release of Nagios 4 from the official website"
cd /tmp
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz	

echo "########### Create a Nagios user and group#####################" 
sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios
usermod -a -G nagcmd apache

echo "########## Extract and install Nagios #################"
tar -xzf nagios-4.4.6.tar.gz
cd nagios-4.4.6

echo "##########Configure and install Nagios ################"
./configure --with-httpd-conf=/etc/apache2/sites-enabled
./configure -with-command-group=nagcmd
sudo make all
sudo make install
sudo make install-init
sudo make install-commandmode
sudo make install-config
sudo /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-enabled/nagios.conf
cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers

echo "############Configure Apache#################"
sudo a2enmod rewrite
sudo a2enmod cgi
sudo systemctl restart apache2

echo "################ Install the Nagios plugins ##################"
cd 
wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
tar -xzf nagios-plugins-2.3.3.tar.gz
cd nagios-plugins-2.3.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
./tools/setup
./configure
sudo make
sudo make install
service nrpe start
	
echo '################ NAGIOS-NRPE-SERVICE #######################'
apt-get install nagios-nrpe-server
service nagios-nrpe-server status

echo '################ Verify the Nagios installation ################'
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

echo '################# Start Nagios and Apache services #######################'
sudo systemctl enable nagios.service
service nagios restart && service apache2 restart 
service nagios status && service apache2 status

echo '------------------------------Create a new user account for Nagios using the htpasswd-----------------------------------'
touch /usr/local/nagios/etc/passwd_users
echo nagiosadmin >> /usr/local/nagios/etc/passwd_users
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin < /usr/local/nagios/etc/passwd_users

echo '-------------------------------------------------Configuring Nagios----------------------------------------------------'
sudo sed -i 's/#cfg_dir=.*/cfg_dir=/usr/local/nagios/etc/servers/g' /usr/local/nagios/etc/nagios.cfg

echo '--------------------------------------------Accessing the Nagios Web Interface------------------------------------------'
###http://nagios_server_public_ip/nagios


################################################## PNP4NAGIOS Installation ###########################################'
apt-get install rrdtool
sudo apt-get install librrds-perl


cd ..
tar -zxvf $NAGIOSPNP
cd pnp4nagios-0.6.25
./configure
make all
make fullinstall
make install-webconf
make install-config
make install-init
sudo systemctl enable npcd
sudo systemctl start npcd
systemctl reload apache2.service
mv  /usr/local/pnp4nagios/share/install.php /usr/local/pnp4nagios/share/install.php.ORI
patch -u /usr/local/nagios/etc/nagios.cfg $PATCH/nagios.patch
patch -u /usr/local/nagios/etc/objects/commands.cfg $PATCH/commands.patch
patch -u /usr/local/nagios/etc/objects/templates.cfg $PATCH/templates.patch
service npcd restart && service nagios restart
cp contrib/ssi/status-header.ssi /usr/local/nagios/share/ssi/
service npcd restart && service nagios restart

###################################### Livestatus Installation ########################################################
sudo apt-get update
sudo apt-get install -y libboost-all-dev g++ make



cd ..
tar -zxvf $MKLIVE
cd mk-livestatus-1.2.6
./configure --with-nagios4
make && make install
cat <<EOT >> /usr/local/nagios/etc/nagios.cfg
broker_module=/usr/local/lib/mk-livestatus/livestatus.o /usr/local/nagios/var/rw/live
EOT
 
#echo 'GET hosts' | unixcat /usr/lib/nagios/mk-livestatus/live

service npcd restart && service apache2 restart && service nagios restart && service nagios-nrpe-server restart

service npcd status && service apache2 status && service nagios status && service nagios-nrpe-server status

########################################################################################################################
													  NAGIOSQL
########################################################################################################################
#Install Prerequisites
sudo apt-get -y install mariadb-server mariadb php-mysql php-pear php-devel libssh2 libssh2-devel
pecl install -f ssh2
echo extension=ssh2.so > /etc/php.d/ssh2.ini

#Create folder for NAGIOS host and service configuration files
mkdir /usr/local/nagios/etc/nagiosql 
mkdir /usr/local/nagios/etc/nagiosql/hosts 
mkdir /usr/local/nagios/etc/nagiosql/services 
mkdir /usr/local/nagios/etc/nagiosql/backup 
mkdir /usr/local/nagios/etc/nagiosql/backup/hosts 
mkdir /usr/local/nagios/etc/nagiosql/backup/services
#Set permission for configuration folder
chown -R apache.nagios /usr/local/nagios/etc/nagiosql

#Provide access to apache for nagios configuration files.
chown apache.nagios /usr/local/nagios/etc/nagios.cfg
chown apache.nagios /usr/local/nagios/etc/cgi.cfg
chown apache.nagios /usr/local/nagios/var/rw/nagios.cmd

chmod 640 /usr/local/nagios/etc/nagios.cfg 
chmod 640 /usr/local/nagios/etc/cgi.cfg 
chmod 660 /usr/local/nagios/var/rw/nagios.cmd 

#Create folder for NAGIOSQL web site
#mkdir /usr/local/nagiosql 
#chown apache /usr/local/nagiosql

systemctl start mariadb
systemctl enable mariadb
mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root@123');"

#Install NagiosQL
cd /usr/local/
wget http://ncu.dl.sourceforge.net/project/nagiosql/nagiosql/NagiosQL%203.2.0/nagiosql_320.tar.gz
tar xzf nagiosql_320.tar.gz
mv nagiosql32 nagiosql
chown -R apache:apache nagiosql
chmod -R 775 nagiosql

touch /etc/apache2/conf.d/nagiosql.conf
sudo tee -i /etc/apache2/conf.d/nagiosql.conf <<EOT
Alias /nagiosql "/usr/local/nagiosql" 
<Directory "/usr/local/nagiosql"> 
     Options None  
     AllowOverride None 
     Order allow,deny 
     Allow from all
     Require all granted 
     #  Order deny,allow 
     #  Deny from all 
     #  Allow from 127.0.0.1 
     #  AuthName "NagiosQL Access" 
     #  AuthType Basic 
     #  AuthUserFile /etc/nagiosql/auth/nagiosql.users 
     #  Require valid-user 
</Directory> 
EOT

sudo sed -i 's/memory_limit = .*/memory_limit = 128M"/g' /etc/php/7.3/apache2/php.ini
sudo sed -i 's/max_execution_time = .*/max_execution_time = 120"/g' /etc/php/7.3/apache2/php.ini
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 20M"/g' /etc/php/7.3/apache2/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 20M"/g' /etc/php/7.3/apache2/php.ini
sudo sed -i 's/date.timezone = .*/date.timezone = "Asia/Kolkata"/g' /etc/php/7.3/apache2/php.ini
sudo sed -i 's/short_open_tag = .*/short_open_tag = On/g' /etc/php/7.3/apache2/php.ini

sudo sed -i 's/SELINUX=.*/SELINUX=disabled"/g' /etc/sysconfig/selinux

cd /usr/local/nagiosql
rm -rf install

chmod 777 /usr/local/nagios/bin/nagios
chown apache:nagios /usr/local/nagios/etc/resource.cfg

# everything and add the below entry
sudo tee -i /usr/local/nagios/etc/nagios.cfg <<EOT
cfg_dir=/usr/local/nagios/etc/nagiosql
EOT

service apache2 restart

http://ip.address/nagiosql 

#Database Type: mysql
#Database Server: localhost
#Local hostname or IP address: localhost
#Database Server Port: 3306
#Database name: db_nagiosql_v32
#NagiosQL DB User: nagiosql_user
#NagiosQL DB Password: 
#Administrative Database User: root
#Administrative Database Password: root123

#Initial NagiosQL User: admin
#Initial NagiosQL Password: admin@123

#NagiosQL Config paths? /usr/local/nagios/etc/nagiosql
#Nagios config path: /usr/local/nagios/etc/

#Nagios command file: /usr/local/nagios/var/rw/nagios.cmd
#Nagios binary file: /usr/local/nagios/bin/nagios
#Nagios process file: /usr/local/nagios/var/nagios.lock
