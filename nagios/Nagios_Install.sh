#!/bin/bash
tmpdir="$(dirname $0)"
echo ${tmpdir} | grep '^/' >/dev/null 2>&1
if [ X"$?" == X"0" ]; then
    export NAGIOSDIR="${tmpdir}"
else
    export NAGIOSDIR="$(pwd)"
fi
echo $NAGIOSDIR
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
echo "This script must be run as root" 1>&2
exit 1
fi
PACKAGE="$NAGIOSDIR/software"
PATCH=$NAGIOSDIR/patch

###Prerequest####
yum clean all
yum clean metadata
yum install epel-release -y
yum clean all
yum clean metadata
yum install automake perl wget httpd php gcc glibc glibc-common gd gd-devel make net-snmp libpng-devel libjpeg-turbo-devel rrdtool perl-Time-HiRes rrdtool-perl php-gd gcc-c++ -y

###Packages###
DOWNLOAD_DIR=$PACKAGE
cd $PACKAGE
NAGIOSPACKAGE=nagios-4.3.1.tar.gz
NAGIOSPNP=pnp4nagios-0.6.25.tar.gz
MKLIVE=mk-livestatus-1.2.6.tar.gz

###Nagios Installation###
useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagcmd apache
tar -zxvf $NAGIOSPACKAGE
cd nagios-4.3.1
./configure -with-command-group=nagcmd
make all
make install
make install-init
make install-commandmode
make install-config
make install-webconf
cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
echo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg > /sbin/nagioschk
chmod 755 /sbin/nagioschk
htpasswd -s -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
service httpd restart && service nagios restart
chkconfig --add nagios && chkconfig --level 35 nagios on
chkconfig httpd on
#firewall-cmd --zone=public --permanent –add-port=80/tcp
#systemctl restart firewalld.service
yum install nagios-plugins-all nagios-plugins-nrpe nrpe -y

###Nagios Plugin###
cd ..
tar -zxvf release-2.1.4.tar.gz
cd nagios-plugins-release-2.1.4/
./tools/setup
./configure
make
make install
service nrpe start
chkconfig nrpe on

###PNP4NAGIOS Installation###
cd ..
tar -zxvf $NAGIOSPNP
cd pnp4nagios-0.6.25
./configure
make all
make fullinstall
chkconfig --add npcd && chkconfig --level 35 npcd on
systemctl reload httpd.service
mv  /usr/local/pnp4nagios/share/install.php /usr/local/pnp4nagios/share/install.php.ORI
patch -u /usr/local/nagios/etc/nagios.cfg $PATCH/nagios.patch
patch -u /usr/local/nagios/etc/objects/commands.cfg $PATCH/commands.patch
patch -u /usr/local/nagios/etc/objects/templates.cfg $PATCH/templates.patch
service npcd restart && service nagios restart
cp contrib/ssi/status-header.ssi /usr/local/nagios/share/ssi/
service npcd restart && service nagios restart

###Livestatus Installation###
cd ..
tar -zxvf $MKLIVE
cd mk-livestatus-1.2.6
./configure --with-nagios4
make && make install
cat <<EOT >> /usr/local/nagios/etc/nagios.cfg
broker_module=/usr/local/lib/mk-livestatus/livestatus.o /usr/local/nagios/var/rw/live
EOT
service nagios restart
#echo 'GET hosts' | unixcat /usr/lib/nagios/mk-livestatus/live

service npcd restart && service httpd restart && service nagios restart && service nrpe restart

service npcd status && service httpd status && service nagios status && service nrpe status

