#!/bin/bash
# https://www.server-world.info/en/note?os=Ubuntu_22.04&p=redmine

### [1] Install Apache2 to Configure HTTP Server
apt -y install apache2 

sudo sed -i 's/ServerTokens .*/ServerTokens Prod/g' /etc/apache2/conf-enabled/security.conf
awk 'NR==2{print "DirectoryIndex index.html index.htm"}1' /etc/apache2/mods-enabled/dir.conf > temp && mv temp /etc/apache2/mods-enabled/dir.conf
awk 'NR==70{print "ServerName www.srv.world"}1' /etc/apache2/apache2.conf > temp && mv temp /etc/apache2/apache2.conf
sudo sed -i 's/ServerAdmin .*/ServerAdmin webmaster@srv.world/g' /etc/apache2/sites-enabled/000-default.conf

systemctl restart apache2 

### [2] Install and start SMTP server
apt -y install postfix sasl2-bin 
cp /usr/share/postfix/main.cf.dist /etc/postfix/main.cf

# line 78 : uncomment 'mail_owner = postfix'
sudo sed -i '/^#mail_owner = postfix/s/^#//g' /etc/postfix/main.cf
# line 94 : uncomment and specify hostname 'myhostname = mail.srv.world'
sudo sed -i '/^#myhostname = .*/s/^#//g' /etc/postfix/main.cf
sudo sed -i 's/myhostname = .*/myhostname = mail.srv.world/g' /etc/postfix/main.cf
# line 102 : uncomment and specify domainname 'mydomain = srv.world'
sudo sed -i '/^#mydomain = .*/s/^#//g' /etc/postfix/main.cf
sudo sed -i 's/mydomain = .*/mydomain = srv.world/g' /etc/postfix/main.cf
# line 123 : uncomment 'myorigin = $mydomain'
sudo sed -i '/^#myorigin = $mydomain/s/^#//g' /etc/postfix/main.cf
# line 137 : uncomment 'inet_interfaces = all'
sudo sed -i '/^#inet_interfaces = all/s/^#//g' /etc/postfix/main.cf
# line 185 : uncomment 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain'
sudo sed -i '/^#mydestination = \$myhostname, localhost\.\$mydomain, localhost, \$mydomain/s/^#//g' /etc/postfix/main.cf
# line 228 : uncomment 'local_recipient_maps = unix:passwd.byname $alias_maps'
sudo sed -i '/^#local_recipient_maps = .*/s/^#//g' /etc/postfix/main.cf
# line 270 : uncomment 'mynetworks_style = subnet'
sudo sed -i '/^#mynetworks_style = subnet/s/^#//g' /etc/postfix/main.cf
# line 287 : add your local network 'mynetworks = 127.0.0.0/8, 10.0.0.0/24'
awk 'NR==287{print "mynetworks = 127.0.0.0/8, 10.0.0.0/24"}1' /etc/postfix/main.cf > temp && mv temp /etc/postfix/main.cf
# line 407 : uncomment 'alias_maps = hash:/etc/aliases'
sudo sed -i '/^#alias_maps = .*/s/^#//g' /etc/postfix/main.cf
# line 418 : uncomment 'alias_database = hash:/etc/aliases'
sudo sed -i '/^#alias_database = .*/s/^#//g' /etc/postfix/main.cf
# line 440 : uncomment 'home_mailbox = Maildir/'
sudo sed -i '/^#home_mailbox = .*/s/^#//g' /etc/postfix/main.cf
# line 576: comment out and add '#smtpd_banner = $myhostname ESMTP $mail_name (Debian/GNU)'
sudo sed -i 's/smtpd_banner = .*/#smtpd_banner = .*/g' /etc/postfix/main.cf
awk 'NR==577{print "smtpd_banner = $myhostname ESMTP"}1' /etc/postfix/main.cf > temp && mv temp /etc/postfix/main.cf
# line 650 : add 'sendmail_path = /usr/sbin/postfix'
awk 'NR==650{print "sendmail_path = /usr/sbin/postfix"}1' /etc/postfix/main.cf > temp && mv temp /etc/postfix/main.cf
# line 655 : add 'newaliases_path = /usr/bin/newaliases'
awk 'NR==655{print "newaliases_path = /usr/bin/newaliases"}1' /etc/postfix/main.cf > temp && mv temp /etc/postfix/main.cf
# line 660 : add 'mailq_path = /usr/bin/mailq'
awk 'NR==660{print "mailq_path = /usr/bin/mailq"}1' /etc/postfix/main.cf > temp && mv temp /etc/postfix/main.cf
# line 666 : add 'setgid_group = postdrop'
awk 'NR==666{print "setgid_group = postdrop"}1' /etc/postfix/main.cf > temp && mv temp /etc/postfix/main.cf
# line 670 : comment out '#html_directory ='
sudo sed -i 's/html_directory = .*/#html_directory = .*/g' /etc/postfix/main.cf
# line 674 : comment out '#manpage_directory ='
sudo sed -i 's/manpage_directory = .*/#manpage_directory = .*/g' /etc/postfix/main.cf
# line 679 : comment out '#sample_directory ='
sudo sed -i 's/sample_directory = .*/#sample_directory = .*/g' /etc/postfix/main.cf
# line 683 : comment out '#readme_directory ='
sudo sed -i 's/readme_directory = .*/#readme_directory = .*/g' /etc/postfix/main.cf
# line 684 : if also listen IPv6, change to [all] "inet_protocols = ipv4"
sudo sed -i 's/inet_protocols = .*/inet_protocols = ipv4/g' /etc/postfix/main.cf
# add follows to the end
sudo echo "   
# disable SMTP VRFY command
disable_vrfy_command = yes

# require HELO command to sender hosts
smtpd_helo_required = yes

# limit an email size
# example below means 10M bytes limit
message_size_limit = 10240000

# SMTP-Auth settings
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_sasl_security_options = noanonymous
smtpd_sasl_local_domain = $myhostname
smtpd_recipient_restrictions = 
  permit_mynetworks,
  permit_sasl_authenticated,
  reject_unauth_destination" \
>> /etc/postfix/main.cf

# Configure additional settings for Postfix if you need.
sudo echo "
# add to the end
# reject unknown clients that forward lookup and reverse lookup of their hostnames on DNS do not match
smtpd_client_restrictions = permit_mynetworks, reject_unknown_client_hostname, permit

# rejects senders that domain name set in FROM are not registered in DNS or 
# not registered with FQDN
smtpd_sender_restrictions = permit_mynetworks, reject_unknown_sender_domain, reject_non_fqdn_sender

# reject hosts that domain name set in FROM are not registered in DNS or 
# not registered with FQDN when your SMTP server receives HELO command
smtpd_helo_restrictions = permit_mynetworks, reject_unknown_hostname, reject_non_fqdn_hostname, reject_invalid_hostname, permit" \
>> /etc/postfix/main.cf

# restart msil-Server
newaliases
systemctl restart postfix 

#### [3] Install PostgreSQL server
#Install and start PostgreSQL
apt -y install postgresql-14 

##By default setting, it's possible to connect to PostgreSQL Server only from Localhost with [peer] authentication.
# listen only localhost by default
grep listen_addresses /etc/postgresql/14/main/postgresql.conf
#listen_addresses = 'localhost' # what IP address(es) to listen on;
# authentication methods by default
grep -v -E "^#|^$" /etc/postgresql/14/main/pg_hba.conf 

## On [peer] authentication, it needs OS user and PostgreSQL user whose name are the same to connect to PostgreSQL Server.
# add an OS user
adduser ubuntu
# add an PostgreSQL user and his Database with PostgreSQL admin user
su - postgres
createuser ubuntu
createdb testdb -O ubuntu
# show users and databases
psql -c "select usename from pg_user;"
psql -l 

## Try to connect to PostgreSQL Database with a user added above. 
# connect to testdb
psql testdb 
# show user roles
testdb=> \du
# show databases
testdb=> \l
# create a test table
testdb=> create table test_table (no int, name text); 
# show tables
testdb=> \dt 
# insert data to test table
testdb=> insert into test_table (no,name) values (01,'Ubuntu'); 
# confirm
testdb=> select * from test_table;
# remove test table
testdb=> drop table test_table; 
testdb=> \dt 
# exit
testdb=> \q 

# remove testdb
dropdb testdb
psql -l 

### [4] Install Ruby
##Install Ruby 3.0 and try to run test script
apt -y install ruby3.0
ruby -v
# verify to create test script
cat > ruby_test.rb <<EOF 
msg = Class.send(:new, String);
mymsg = msg.send(:new, "Hello Ruby World !\n");
STDOUT.send(:write, mymsg)
EOF

ruby ruby_test.rb

###[5] Install other required packages. 
apt -y install ruby-dev postgresql-server-dev-all libxslt1-dev libxml2-dev libpq-dev libcurl4-openssl-dev zlib1g-dev apache2-dev gcc g++ make patch imagemagick 

###[6] Create a user and database for Redmine on PostgreSQL.
# set any password for [password] section
su - postgres
createuser redmine
createdb redmine -O redmine
psql -c "alter user redmine with password 'password'"
#ALTER ROLE 	

###[7] Download and install Redmine. Make sure the latest version on the site below.
curl -O https://www.redmine.org/releases/redmine-5.0.3.tar.gz
tar zxvf redmine-5.0.3.tar.gz
mv redmine-5.0.3 /var/www/redmine
cd /var/www/redmine
sudo tee -i config/database.yml <<EOF
# create new
production:
  adapter: postgresql
  # database name
  database: redmine
  host: localhost
  # database user
  username: redmine
  # database user' password
  password: password
  encoding: utf8
EOF

sudo tee -i config/configuration.yml <<EOF
# create new (SMTP settings)
production:
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      address: "localhost"
      port: 25
      domain: 'dlp.srv.world'
EOF

# install bundler
gem install bundler
# install Gems for Redmine
bundle config set --local without 'development test mysql sqlite'
bundle install
# generate keys
bundle exec rake generate_secret_token
# generate tables
bundle exec rake db:migrate RAILS_ENV=production
# install Passenger
gem install passenger
# install modules for Apache2
passenger-install-apache2-module

sudo tee -i /var/lib/gems/3.0.0/gems/passenger-6.0.15/buildout/apache2/mod_passenger.so <<EOF
   <IfModule mod_passenger.c>
     PassengerRoot /var/lib/gems/3.0.0/gems/passenger-6.0.15
     PassengerDefaultRuby /usr/bin/ruby3.0
   </IfModule>
EOF

sudo systemctl restart apache2

###[8] Configure Apache2 to run Passenger
sudo tee -i /etc/apache2/conf-available/passenger.conf <<EOF
# create new
LoadModule passenger_module /var/lib/gems/3.0.0/gems/passenger-6.0.15/buildout/apache2/mod_passenger.so
PassengerRoot /var/lib/gems/3.0.0/gems/passenger-6.0.15
PassengerDefaultRuby /usr/bin/ruby3.0
SetEnv LD_LIBRARY_PATH /usr/lib64

<VirtualHost *:80>
    ServerName redmine.srv.world
    DocumentRoot /var/www/redmine/public
</VirtualHost>

<Directory "/var/www/redmine/public">
    Options FollowSymLinks
    AllowOverride All
</Directory>
EOF

chown -R www-data. /var/www/redmine
a2enconf passenger
systemctl reload apache2 

###[9] Access to the URL you configured on Apache2, then Redmine's index site is shown like follows. Click [Sing in] link. 
###[10] Login with the initial username/password [admin/admin]. 
###[11] After initial login, changing password is required. 
###[12] After changing password, setting of account information is required, input them. 
###[13] That's OK, Create Projects and use Redmine. 
