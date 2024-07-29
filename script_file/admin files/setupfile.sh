
cd /home/js/Downloads/
# JAVA 17
wget https://download.oracle.com/java/17/archive/jdk-17.0.9_linux-x64_bin.deb
# TOMCAT 10
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.16/bin/apache-tomcat-10.1.16.tar.gz
# ELASTICSEARCH
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.11.1-linux-x86_64.tar.gz
# LOGSTASH
wget https://artifacts.elastic.co/downloads/logstash/logstash-8.11.1-linux-x86_64.tar.gz
# FILEBEAT
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.11.1-linux-x86_64.tar.gz
# SQL-DEVELOPER ORACLE
wget https://download.oracle.com/otn/java/sqldeveloper/sqldeveloper-23.1.0.097.1607-no-jre.zip
# NAGIOS 
wget https://go.nagios.org/get-core/4-5-0/
wget https://go2.nagios.com/get-xi/source
https://www.nagios.com/products/nagios-xi/downloads/
https://www.nagios.com/products/nagios-log-server/downloads/
https://www.nagios.com/products/nagios-network-analyzer/downloads/
https://www.nagios.com/products/nagios-fusion/downloads/
# VMWARE NAGIOS
Workstation Pro/Player		https://go2.nagios.com/get-xi/ova
ESXi and vSphere			https://go2.nagios.com/get-xi/ova
# windows NAGIOS
Open Virtualization Format      https://go2.nagios.com/get-xi/ova
Hyper-V                     	https://go2.nagios.com/get-xi/vpc


# JAVA
wget https://download.oracle.com/java/17/archive/jdk-17.0.9_linux-x64_bin.deb
sudo dpkg -i jdk-17.0.9_linux-x64_bin.deb
java -V

# TOMCAT
mkdir /opt/tomcat
mkdir /opt/tomcat/server
mkdir /opt/tomcat/service
sudo tar -xzvf apache-tomcat*.tar.gz -C /opt/tomcat/server --strip-components=1
sudo tar -xzvf apache-tomcat*.tar.gz -C /opt/tomcat/service --strip-components=1
chmod 755 /opt/tomcat/server/bin/*
chmod 755 /opt/tomcat/service/bin/*

#ELASTICSEARCH
mkdir /opt/elasticsearch
sudo tar -zxvf elasticsearch-8.11.1-linux-x86_64.tar.gz -C /opt/elasticsearch --strip-components=1

# LOGSTASH
mkdir /opt/logstash
sudo tar -zxvf logstash-8*.tar.gz -C /opt/logstash --strip-components=1

#FILEBEAT
mkdir /opt/filebeat
sudo tar -zxvf filebeat-8*.tar.gz -C /opt/filebeat --strip-components=1

# MYSQL
service mysql stop
nano /etc/mysql/mysql.conf.d/mysqld.cnf
#echo lower_case_table_names=1 >/etc/mysql/mysql.conf.d/mysqld.cnf
cp -r /var/lib/mysql /var/lib/mysql_backup
rm -rf /var/lib/mysql
mkdir /var/lib/mysql
chmod -R 700 /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
mysqld --defaults-file=/etc/mysql/my.cnf --initialize --user=mysql --lower_case_table_names=1 --console
service mysql start
service mysql status

# SQL-DEVELOPER
unzip sqldeveloper-23.1.0.097.1607-no-jre.zip
cp -r sqldeveloper* /opt/
sudo chmod +x /opt/sqldeveloper/sqldeveloper.sh
./sqldeveloper.sh


